Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:34499 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932995Ab2FGV7g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 17:59:36 -0400
Message-ID: <4FD1242E.1010909@panasas.com>
Date: Fri, 8 Jun 2012 00:59:10 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Namjae Jeon <linkinjeon@gmail.com>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        Amit Sahrawat <a.sahrawat@samsung.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Namjae Jeon <namjae.jeon@samsung.com>
Subject: Re: [Problem]NFS Server =?UTF-8?B?4oCTIFVtb3VudCByZXN1bHRzIGluIEQ=?=
 =?UTF-8?B?ZXZpY2UgQnVzeS4=?=
References: <CAKYAXd-HCfcejT=kG-kSXWCmfmxTjrT2o+b3Zan+BCrS1Y2ovw@mail.gmail.com> <4FD06290.7050004@panasas.com> <20120607113358.GB8684@fieldses.org>
In-Reply-To: <20120607113358.GB8684@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/07/2012 02:33 PM, J. Bruce Fields wrote:

> On Thu, Jun 07, 2012 at 11:13:04AM +0300, Boaz Harrosh wrote:


> 
> I'm not sure how adding an "unmount" rpc to the protocol would really
> help here, if that's what you're asking for.
> 


Please elaborate a bit. I'm not familiar with the details of this
discussion.

> If you're just looking for a command you could run on the server after
> all the clients have unmounted--"exportfs -f" or "service stop nfsd" (or
> equivalent) should do the job.
> 

man exportfs
       -f     In 'new' mode, flush everything out of the kernels export table.
              Any clients that are active will get new entries added by mountd
              when they make their next request.

What if: (Just fantasizing here, if I understand the above text correctly)
* NFS4: A bit like expire client, as long as client has state on the server
        he needs to refresh his leases so not to expire with some kind of
        activity or renewals.
	If a client has no state and 2*expiry timeout passed then it is
	individually "exportfs -f". This is safe because on renewed activity
	it will get it's mountd entries renewed safely (did I understand
	this correctly?

* NFS3: Same as above But with say X*expiry timeout after last activity
	Same safeness as above.

Any "unmount rpc" will expedite the above without waiting for timeout

<>

> 
> Note nfsd doesn't really know when that is.  Even with NFSv4, processes
> can be using the filesystem without holding state on the server: they
> might just have a current working directory in the filesystem, or have a
> device special file open.
> 


How does the magic of above statement works? quote:
    "will get new entries added by mountd when they make their next request"

<>

> 
> My first concern would be to fix any ordering bugs in the systemd
> configuration, or any reference count leaks.
> 


I'm currently shooting in the dark, I have not investigated this at all,
do to lack of time. It should be the same with an ext4 over iscsi device
re-exported by NFS. You must mount the ext4 as "-o _netdev" otherwise
ext4 mount itself will have a problem.

> --b.


Thanks Bruce, we'll keep this on a back burner until we can come back to
it. A TODO.

But Jeon, please do send in your proposal code, I'd like to see it.

Thanks
Boaz
