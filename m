From: Michael Haverkamp <mhaverkamp@kcp.com>
Subject: Re: Stale NFS Filehandles and Permission Denied on 2.6.9
Date: Tue, 23 Nov 2004 08:06:00 -0600
Message-ID: <41A343C8.7090106@kcp.com>
References: <41A28FE0.9070906@affymetrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWbJ7-0006JI-09
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 06:06:13 -0800
Received: from mailhost2.os.kcp.com ([198.124.201.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CWbJ5-0005Zq-37
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 06:06:12 -0800
To: Hugh Caley <Hugh_Caley@affymetrix.com>, nfs@lists.sourceforge.net
In-Reply-To: <41A28FE0.9070906@affymetrix.com>
Sender: nfs-admin@lists.sourceforge.net
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

I had similar problems.  Downgrading to kernel 2.6.7 and using 
no_subtree_check seemed to fix it for me.  I'm not sure which one fixed 
it, or if it was both.

Hugh Caley wrote:
> We recently migrated our main storage to a Nexsan Atabeast fronted by 
> two PC's running Fedora Core 2.   We are being plagued by  "Stale NFS 
> Filehandle" and "Permission Denied" errors on machines mounting the 
> shares provided by the two PC's.  Very sporadic, but annoying.
> 
> I can't seem to find any rhyme or reason for this.  Clients that have 
> seen the problem include a machine running RH 7.3 accessing a mount in 
> fstab, to a Fedora Core 1 client automounting a share.  Many times just 
> running 'ls' on the share a few times will suddenly make it accessable.  
> Other times a umount/mount is required.
> 
> The server machines are running Fedora Core 2 and kernel 
> 2.6.9-1.3_FC2smp.  The exported filesystems are ReiserFS on LVM2 
> volumes.  Qlogic QLA2300 fibre adaptors connect the heads to the Nexsan 
> Atabeast.
> 
> After reading some traffic on the Linux kernel list, I added the 
> "no_subtree_check" option to the fstab entries on the servers and 
> re-exported.  It doesn't seem to have made much of a difference.
> 
> I'm not seeing error messages in /var/log/messages on either the clients 
> nor the hosts.
> 
> Anyone else seeing this?  Any ideas?  Otherwise the performance on the 
> new systems beats the hell out of our old EMC Celerra; the users are 
> rather happy with it save for this little problem.
> 
> Hugh
> 

-- 
Michael Haverkamp



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
