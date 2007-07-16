From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] fix broken compile due to missing pseudoflavors.h
Date: Mon, 16 Jul 2007 13:26:48 -0400
Message-ID: <469BAA58.20703@oracle.com>
References: <469AB4D6.20902@oracle.com> <20070716170608.GD2817@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060804080504000400050202"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS mailing list <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAUM9-0007Wk-DC
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 10:27:34 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAUMB-0002Zc-RL
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 10:27:37 -0700
In-Reply-To: <20070716170608.GD2817@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------060804080504000400050202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

FYI:

Yes, this fixes the build breakage with "./configure --disable-gss 
--disable-nfsv4"

J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Commit e9b0bed761bc77ba046f53be2ec324c4b61357ff should also have added
> this file.
> 
> Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> ---
>  support/include/pseudoflavors.h |   17 +++++++++++++++++
>  1 files changed, 17 insertions(+), 0 deletions(-)
>  create mode 100644 support/include/pseudoflavors.h
> 
> On Sun, Jul 15, 2007 at 07:59:18PM -0400, Chuck Lever wrote:
>> Making all in nfs
>> make[2]: Entering directory `/u/cel/nfs-utils/support/nfs'
>> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I../../support/include 
>> -D_GNU_SOURCE -Wall  -pipe -g -O2 -MT exports.o -MD -MP -MF 
>> .deps/exports.Tpo -c -o exports.o exports.c
>> exports.c:33:27: error: pseudoflavors.h: No such file or directory
> 
> Whoops, I should have actually looked at the compile output yesterday
> before jumping to conclusions.  Looks like pseudoflavors.h didn't get
> added to the git repo.  (Neil--just pipe a mailbox to "git am", and
> it'll take care of adding new files.)
> 
> (I haven't checked yet whether it's still OK with --disable-gss and
> --disable-nfsv4....)
> 
> --b.
> 
> diff --git a/support/include/pseudoflavors.h b/support/include/pseudoflavors.h
> new file mode 100644
> index 0000000..c21087b
> --- /dev/null
> +++ b/support/include/pseudoflavors.h
> @@ -0,0 +1,17 @@
> +#define RPC_AUTH_GSS_KRB5       390003
> +#define RPC_AUTH_GSS_KRB5I      390004
> +#define RPC_AUTH_GSS_KRB5P      390005
> +#define RPC_AUTH_GSS_LKEY       390006
> +#define RPC_AUTH_GSS_LKEYI      390007
> +#define RPC_AUTH_GSS_LKEYP      390008
> +#define RPC_AUTH_GSS_SPKM       390009
> +#define RPC_AUTH_GSS_SPKMI      390010
> +#define RPC_AUTH_GSS_SPKMP      390011
> +
> +struct flav_info {
> +	char    *flavour;
> +	int     fnum;
> +};
> +
> +extern struct flav_info flav_map[];
> +extern const int flav_map_size;

--------------060804080504000400050202
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------060804080504000400050202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------060804080504000400050202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060804080504000400050202--
