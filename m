From: "NeilBrown" <neilb@suse.de>
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
     Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Tue, 16 Jun 2009 10:50:57 +1000 (EST)
Message-ID: <02ada87c636e1088e9365a3cbea301e7.squirrel@neil.brown.name>
References: <OF37FCED66.33F08949-ON852575CB.006DE109-852575CB.0071CFBD@us.ibm.com>
    <4A2902E6.2080006@RedHat.com> <4A29144A.6030405@gmail.com>
    <4A291DE3.2070105@RedHat.com>
    <1244209956.5410.33.camel@heimdal.trondhjem.org>
    <4A29243F.8080008@RedHat.com> <20090605160544.GE10975@fieldses.org>
    <1244219715.5410.40.camel@heimdal.trondhjem.org>
    <20090615230801.GA18504@fieldses.org>
    <99d4545537613ce76040d3655b78bdb7.squirrel@neil.brown.name>
    <20090616003357.GB19396@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Steve Dickson" <steved@redhat.com>,
	"Tom Talpey" <tmtalpey@gmail.com>,
	"Linux NFS Mailing list" <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55979 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600AbZFPAvG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 20:51:06 -0400
In-Reply-To: <20090616003357.GB19396@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, June 16, 2009 10:33 am, J. Bruce Fields wrote:
> On Tue, Jun 16, 2009 at 10:21:50AM +1000, NeilBrown wrote:
>> On Tue, June 16, 2009 9:08 am, J. Bruce Fields wrote:
>>
>> > +	if (host_err >= 0 && stable)
>> > +		wait_for_concurrent_writes(file, use_wgather, &host_err);
>> >
>>
>> Surely you want this to be:
>>
>>    if (host_err >= 0 && stable && use_wgather)
>>          host_err = wait_for_concurrent_writes(file);
>> as
>>  - this is more readable
>>  - setting last_ino and last_dev is pointless when !use_wgather
>
> Yep, thanks.
>
>>  - we aren't interested in differentiation between non-negative values
>> of
>>    host_err.
>
> Unfortunately, just below:
>
> 	if (host_err >= 0) {
> 		err = 0;
> 		*cnt = host_err;
> 	} else
> 		err = nfserrno(host_err);
>

Ahh.... that must be in code you haven't pushed out yet.
I don't see it in mainline or git.linux-nfs.org

> We could save that count earlier, e.g.:
>
> @@ -1014,6 +1013,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh
> *fhp,
>         int                     host_err;
>         int                     stable = *stablep;
>         int                     use_wgather;
> +       int                     bytes;
>
>  #ifdef MSNFS
>         err = nfserr_perm;
> @@ -1056,6 +1056,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh
> *fhp,
>         set_fs(oldfs);
>         if (host_err >= 0) {
>                 nfsdstats.io_write += host_err;
> +               bytes = host_err;
>                 fsnotify_modify(file->f_path.dentry);

Or even

   if (host_err >= 0) {
          bytes = host_err;
          nfsdstats.io_write += bytes
           ...

And if you did that in whatever patch move the assignment to
*cnt to the bottom of the function, it might be even more readable!

Thanks,
NeilBrown


