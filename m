From: Guochun Shi <gshi@ncsa.uiuc.edu>
Subject: Re: failover-NFS server problem
Date: Tue, 20 Apr 2004 11:58:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.1.0.14.2.20040420115355.00ae09c0@pop.ncsa.uiuc.edu>
References: <5.1.0.14.2.20040420111313.00ad1d68@pop.ncsa.uiuc.edu>
 <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
 <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
 <5.1.0.14.2.20040420111313.00ad1d68@pop.ncsa.uiuc.edu> <4085533C.6070801@unix.sh>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFyZO-0002Oj-9i
	for nfs@lists.sourceforge.net; Tue, 20 Apr 2004 09:58:02 -0700
Received: from mail.ncsa.uiuc.edu ([141.142.2.28])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFyZN-00045D-Rw
	for nfs@lists.sourceforge.net; Tue, 20 Apr 2004 09:58:01 -0700
To: Alan Robertson <alanr@unix.sh>
In-Reply-To: <4085533C.6070801@unix.sh>
References: <5.1.0.14.2.20040420111313.00ad1d68@pop.ncsa.uiuc.edu>
 <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
 <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
 <5.1.0.14.2.20040420111313.00ad1d68@pop.ncsa.uiuc.edu>
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

At 10:43 AM 4/20/2004 -0600, you wrote:
>Guochun Shi wrote:
>>At 01:10 AM 4/20/2004 +0200, Ragnar =?iso-8859-15?Q?Kjo=F8rstad?= wrote:
>>
>>>On Mon, Apr 19, 2004 at 01:14:24PM -0500, Guochun Shi wrote:
>>>
>>>>I ran into some problem in running Connectathon with NFS. The scenario I want to test is if NFS works fine in case of the server is failed back and forth (linuxHA controls that. Linux-Ha is in www.linux-ha.org ). The following is my setup:
>>>>
>>>>1. Machine A and Machine B are servers, there is one and only server active any time. The active machine has a floating IP as the service IP.
>>>>2. Machine C is the client. It mounts a directory from the floating IP
>>>>3. Machine A and Machine B have a fiber channel share disk. The exported filesystem resides in shared disk. On both machines, /var/lib/nfs is a symbolic link to a directory in the shared disk.
>>>>
>>>>all machines are running Redhat 9, kernel 2.4.26, with nfs-utils-1.0.1-2.9
>>>>
>>>>The server will switch between A and B, in each switching:
>>>>the original server will stop nfs, stop nfslock, umount from the shared disk and give out the floating ip, the backup server will grab the floaing ip, mount the shared disk, start nfslock and start nfs
>>>
>>>Did you modify the init-scripts to supply the "-n" option to rpc.statd?
>>>
>>>Statd needs to use the same name on both servers (the one used by your
>>>clients to mount filesystems) for locking to work accross failures.
>>>
>>>The init-script in nfs-utils in RH9 doesn't support this. Take a look at
>>>the init-script in Fedora Core 1 or the official nfs-utils package.
>>>(Possible you can just upgrade to FC1's nfs-utils 1.0.6.
>>>
>>>Then you need to change the sysconfig-files to set the STATD_HOSTNAME
>>>variable to match the name of the floating IP. 
>>thanks for your reply, Ragnar, I modified the init.d/nfslock script to supply STATD_HOSTNAME to rpc.statd and and are now re-running the test. So far so good.
>
>Hi Guochun,
>
>This was mentioned in both my article and the one specifically on NFS with Linux-HA.  I didn't realize you hadn't done this...


I shall go back to read the articles more carefully:). 

I failed the test again after those modifications :-( 
and I don't think those warning messages the reason to failure since I got it almost once in several seconds.

-Guochun



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
