Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44198 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751928AbdFNOKE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jun 2017 10:10:04 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: "nfs4_discover_server_trunking unhandled error" on Ctrl-C
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1497443353.6752.5.camel@redhat.com>
Date: Wed, 14 Jun 2017 10:09:48 -0400
Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "William A. (Andy) Adamson" <andros@netapp.com>
Message-Id: <FE3D3FA5-6C2F-4F02-9498-7DCBB945B99F@oracle.com>
References: <991293071.14131572.1497360717136.JavaMail.zimbra@desy.de> <CAN-5tyHeaNHVxQLnXVfQyyS20jwk0L-2UjY-pH-azM6ADQBEtQ@mail.gmail.com> <1087115680.14242025.1497381738583.JavaMail.zimbra@desy.de> <1497443353.6752.5.camel@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 14, 2017, at 8:29 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> That warning has been around for a long time. We're running the server
> trunking check and caught a signal in the middle of it. It's harmless,
> AFAICT.
> 
> Should we merge a patch like this (untested) one, just to silence it? It
> really is an expected situation that we needn't warn anyone about:
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index b34de036501b..ae9a9ad2894d 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2182,6 +2182,9 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
>                                 * in nfs4_exchange_id */
>                status = -EKEYEXPIRED;
>                break;
> +       case -ERESTARTSYS:
> +               status = -EINTR;
> +               break;
>        default:
>                pr_warn("NFS: %s unhandled error %d. Exiting with error EIO\n",
>                                __func__, status);

I agree that this message is noise in this case, and the patch
looks sane.


> On Tue, 2017-06-13 at 21:22 +0200, Mkrtchyan, Tigran wrote:
>> Hi Olga,
>> 
>> this is 4.12.-rc4.  I will check packet capture tomorrow, however, I am pretty sure that
>> this is client internal interrupt processing.
>> 
>> Tigran.
>> 
>> ----- Original Message -----
>>> From: "Olga Kornievskaia" <aglo@umich.edu>
>>> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
>>> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Andy Adamson" <andros@netapp.com>
>>> Sent: Tuesday, June 13, 2017 6:21:01 PM
>>> Subject: Re: "nfs4_discover_server_trunking unhandled error" on Ctrl-C
>>> On Tue, Jun 13, 2017 at 9:31 AM, Mkrtchyan, Tigran
>>> <tigran.mkrtchyan@desy.de> wrote:
>>>> 
>>>> If I hit Ctrl-C during mount, then I see following message in the log file:
>>>> 
>>>> NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO
>>>> 
>>>> 
>>>> produced at nfs4state.c:2533. Is this expected behavior?
>>> 
>>> What kernel version (or upstream commit) is that? Is this
>>> reproducible? Anything on the network trace that server returns that
>>> could explain an error it doesn't expect. Also I'm thinking that
>>> nfs_wait_client_init_complete() could be interrupted by ctrl-c and
>>> return ERESTARTSYS and that could translate to "unhanded error".
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



