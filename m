Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:36452 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759629AbaJ3Nbh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Oct 2014 09:31:37 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2] common:  Fixes for testing NFS over IPv6
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1414674456-9097-1-git-send-email-Anna.Schumaker@Netapp.com>
Date: Thu, 30 Oct 2014 09:31:10 -0400
Cc: fstests@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1C161804-AFC6-482E-9AE9-AD66605A707F@oracle.com>
References: <1414674456-9097-1-git-send-email-Anna.Schumaker@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

On Oct 30, 2014, at 9:07 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> When testing NFS over IPv6, the user will set a $TEST_DEV of the form
> [fe80::42]:/export.

Fixing how fstests handles raw IPv6 addresses is a good idea.

However, testing NFS over IPv6 can be done in other ways. The
preferred way this is done is by providing a DNS AAAA record
for the NFS server (or by fixing up /etc/hosts), and then
using “proto=tcp6” or “proto=udp6” when mounting the server.

I just mention that because people shouldn’t get the idea that
NFS IPv6 testing can only be done using a raw link-local address.

Could the first line of the patch description be changed to say
“When testing NFS by mounting the NFS server with a raw IPv6 address,
the user . . .” ?

The rest seems reasonable to me.

> The use of square brackets surrounding the IPv6
> address is an accepted convention, but grep and awk think that our IPv6
> address is actually a regex and tries to evaluate it instead.  The
> result is that xfstests reports our filesystem "is busy or already
> mounted".
> 
> This patch fixes the IPv6 problem by telling awk and grep to treat
> $TEST_DEV as a fixed string rather than a regex.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
> common/rc | 12 ++++++++----
> 1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/common/rc b/common/rc
> index 747cf72..9f17564 100644
> --- a/common/rc
> +++ b/common/rc
> @@ -809,14 +809,16 @@ _df_device()
> 	exit 1
>     fi
> 
> +    # Note that we use "==" here so awk doesn't try to interpret an NFS over
> +    # IPv6 server as a regular expression.
>     $DF_PROG 2>/dev/null | $AWK_PROG -v what=$1 '
> -        match($1,what) && NF==1 {
> +        ($1==what) && (NF==1) {
>             v=$1
>             getline
>             print v, $0
>             exit
>         }
> -        match($1,what) {
> +        ($1==what) {
>             print
>             exit
>         }
> @@ -1132,10 +1134,12 @@ _require_test()
>     esac
> 
>     # mounted?
> -    if _mount | grep -q $TEST_DEV
> +    # Note that we use -F here so grep doesn't try to interpret an NFS over
> +    # IPv6 server as a regular expression.
> +    if _mount | grep -F -q $TEST_DEV
>     then
>         # if it's mounted, make sure its on $TEST_DIR
> -        if ! _mount | grep $TEST_DEV | grep -q $TEST_DIR
> +        if ! _mount | grep -F $TEST_DEV | grep -q $TEST_DIR
>         then
>             echo "\$TEST_DEV is mounted but not on \$TEST_DIR - aborting"
>             exit 1
> -- 
> 2.1.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



