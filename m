From: James Pearson <james-p@moving-picture.com>
Subject: Re: acl_extended_file() and NFS file systems
Date: Thu, 24 Jun 2004 16:32:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40DAF3F1.7030006@moving-picture.com>
References: <40D9ABC9.1070007@moving-picture.com> <40D9C796.6000904@RedHat.com> <40D9FC0B.6050401@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdWDB-0002To-Ik
	for nfs@lists.sourceforge.net; Thu, 24 Jun 2004 08:32:25 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BdWDA-0002L9-9a
	for nfs@lists.sourceforge.net; Thu, 24 Jun 2004 08:32:24 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40D9FC0B.6050401@moving-picture.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I think I've worked out what is going on ... when I said the client was
a FC1 box, I didn't give all the facts - it's using a kernel based on
the FC1 kernel - actually one from ATrpms (http://atrpms.net/).

It turns out that this kernel has a 'nfsacl' patch (from 
http://acl.bestbits.at/download.html) applied that
adds CONFIG_NFS_ACL (and CONFIG_NFSD_ACL) which are enabled by default -
compiling a new kernel with the CONFIG_NFS_ACL option disabled (i.e.
something closer to a vanilla FC1 kernel), then the problem goes away ...

James Pearson

James Pearson wrote:
> I've put the strace and ethereal outputs at:
> 
> ftp://ftp.moving-picture.com/private/nfs/
> 
> The files 'works' from using a file on a FC1 server
> 
> The files 'fails' from using a file on a RH7.2 server
> 
> Note: it also fails on NFS files from an Irix 6.5.X server
> 
> James Pearson
> 
> Steve Dickson wrote:
> 
>> James Pearson wrote:
>>
>>> We've just come across a problem with running 'ls -l' on NFS mounted 
>>> files from a client running Fedora Core 1 with the latest coreutils 
>>> RPM (5.0-34.1)
>>>
>>> Running ls -l on a file exported by a RedHat 7.2 system gives
>>>
>>> % ls -l /some/remote/file
>>> ls: /some/remote/file: Input/output error
>>> -rw-rw-r--  1 james user 17373 Jun  1 20:02 /some/remote/file
>>
>>
>>
>> hmm... it sound like 7.2 is returning garbage but to which
>> over-the-wire operation? Since FC1 does not have ACL support so
>> the getxattr() (that is done by your test program) should
>> be returned EOPNOTSUPP (as it does in my testing) but instead
>> it sounds like the FC1 is actually trying to send something otw..
>> Would it be possible to get a strace and ethereal trace of this
>> phenomenon?
>>
>> SteveD.
>>
>>
>>
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email sponsored by Black Hat Briefings & Training.
> Attend Black Hat Briefings & Training, Las Vegas July 24-29 - digital 
> self defense, top technical experts, no vendor pitches, unmatched 
> networking opportunities. Visit www.blackhat.com
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 




-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
