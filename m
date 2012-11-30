Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.cim.mcgill.ca ([132.206.73.2]:40496 "EHLO
	orford.cim.mcgill.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436Ab2K3ByF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 20:54:05 -0500
Message-ID: <50B811BA.6070503@cim.mcgill.ca>
Date: Thu, 29 Nov 2012 17:54:02 -0800
From: Patrick McLean <patrick@cim.mcgill.ca>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: Patrick McLean <patrickm@gaikai.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Regression with initramfs and nfsroot (appears to be in the dcache)
References: <CAE2NFgU+4QDcLaVE5dKDvZCxey7qEf7FAbYNjNmcjVU=HLhF=A@mail.gmail.com> <20121129213316.GU4939@ZenIV.linux.org.uk> <CAE2NFgWCnmgSCsw7MzRkqBLTHgRDG-FvKKcbTHN6UqePK6Ef+Q@mail.gmail.com> <20121129222109.GW4939@ZenIV.linux.org.uk> <50B7E759.9070007@gaikai.com> <20121129234326.GX4939@ZenIV.linux.org.uk> <50B7FBA7.2030300@gaikai.com> <20121130003502.GY4939@ZenIV.linux.org.uk> <50B8046F.7030308@cim.mcgill.ca> <20121130013628.GZ4939@ZenIV.linux.org.uk>
In-Reply-To: <20121130013628.GZ4939@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29/11/12 05:36 PM, Al Viro wrote:
> On Thu, Nov 29, 2012 at 04:57:19PM -0800, Patrick McLean wrote:
>>> Interesting...  Server-side that should've been produced by
>>> encode_entryplus_baggage(), which looks like failing compose_entry_fh()...
>>> which has explicit
>>>         if (d_mountpoint(dchild))
>>>                 goto out;
>>> resulting in ENOENT on everything that's overmounted on server.
>>>
>>> Do you, by any chance, have the server really exporting its own root
>>> filesystem?  Another thing to check: have nfs_prime_dcache() print
>>> filename.name of everything that fails nfs_same_entry() and has
>>> zero entry->fh->size, regardless of d_invalidate() results.
>>
>> The server is running 3.6.6 and is just exporting a subdir of an xfs filesystem (which does not happen to be the root filesystem).
>>
>> The client is running as a KVM guest on the machine that is serving the NFS. I am reproducing this by booting the guest via an initramfs, and doing
>> "ls /" at in single user mode.
>>
>> I added a check that prints the filename.name of everything that fails nfs_same_file, and it appears to just be triggered by the same filesystems that
>> are triggering the WARN_ON, the relevant dmesg is below.
> 
> [the same /dev, /proc and /sys]
> 
> 	Very interesting.  Do you have anything mounted on the corresponding
> directories on server?  The picture looks like you are getting empty
> fhandles in readdir+ respons for exactly the same directories that happen
> to be mountpoints on client.  In any case, we shouldn't do that blind
> d_drop() - empty fhandles can happen.  The only remaining question is
> why do they happen on that set of entries.  From my reading of
> encode_entryplus_baggage() it looks like we have compose_entry_fh()
> failing for those entries and those entries alone.  One possible cause
> would be d_mountpoint(dchild) being true on server.  If it is true, we
> can declare the case closed; if not, I really wonder what's going on.

Those directories do have the server's own copies of the said directories bind mounted at the moment in a separate mount namespace.

Unmounting those directories on the server does appear to stop the WARN_ON from triggering.

> Note that if the same fs is mounted elsewhere, d_mountpoint() would mean
> that something is mounted on top of that directory in _some_ instance;
> not necessary the exported one.  Can you slap printks on fs/nfsd/nfs3xdr.c
> compose_entry_fh() failure exits and see which one triggers server-side?
