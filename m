From: James Pearson <james-p@moving-picture.com>
Subject: Re: 32 bit stat() on a 64 bit kernel failing on a large NFS
 filesystem?
Date: Thu, 22 Jun 2006 11:44:27 +0100
Message-ID: <449A748B.9030600@moving-picture.com>
References: <4497D670.2040900@moving-picture.com>
	<200606201330.09563.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtMfy-0002Be-AI
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 03:44:42 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FtMfw-0000Qj-4h
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 03:44:42 -0700
To: Bernd Schubert <bernd-schubert@gmx.de>
In-Reply-To: <200606201330.09563.bernd-schubert@gmx.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Bernd Schubert wrote:
> On Tuesday 20 June 2006 13:05, James Pearson wrote:
> 
>>I recently found a problem running a 32bit (i686) binary on a 64bit
>>(x86_64) kernel that fails when stat'ing any file on a multi-TB NFS
>>clustered file system (a non-Linux file system).
>>
>>stat() returns EOVERFLOW (Value too large for defined data type)
>>
>>The same 32bit binary running on a 32bit kernel stat'ing the same files
>>works OK.
>>
>>In both cases, I'm using RHEL4 based distros on the clients (I also
>>tried a generic 2.6.16.x kernel on the 64 bit client, but that made no
>>difference).
>>
>>We can work round the problem by either making sure the binary is
>>compiled with _FILE_OFFSET_BITS set to 64, or configuring the NFS file
>>server to use 32 bit 'file IDs'.
>>
>>My question are:
>>
>>Is this a 'bug' or 'feature' with using a 32 bit app on a 64 bit kernel?
>>
>>If it's a 'feature', can anyone explain why it works in this way?
> 
> 
> I already had the same problem, just see this thread:
> 
> http://lkml.org/lkml/2005/2/28/172

Thanks - that thread sort of explains what is going on ...

James Pearson

All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
