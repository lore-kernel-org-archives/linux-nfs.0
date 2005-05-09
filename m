From: David Cureton <david.cureton@catapult.com>
Subject: Re: Accessing other shares from NFS mounted home directories
Date: Tue, 10 May 2005 09:39:40 +1000
Message-ID: <427FF4BC.2090705@catapult.com>
References: <1115647866.21417.51.camel@vserver.central-data.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVHqn-0005CH-S4
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 16:39:49 -0700
Received: from [192.94.66.29] (helo=catapult-mx.catapult.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DVHqm-0000cm-Cr
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 16:39:49 -0700
To: Murray Trainer <mtrainer@central-data.net>
In-Reply-To: <1115647866.21417.51.camel@vserver.central-data.net>
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


Hi Murray,   
     If I understand you, what you are trying to do is mount NFS 
filesystems on mount points that are itself an nfs filesystem.
We are currently do just this and it appears to work OK. We are having 
one slight isolated problem with a symbolic link going missing however 
this may or may not be due to mounting the mountpoints via NFS.

Basically here I export the directory:
/server
 which contains the directorys  (which I use as mount points for the 
actual disk patitions of the server and as NFS mountpoint  on the client)
/server/volumes/vol1
/server/volumes/vol2
/server/volumes/vol3
 

Then on the clients I go about mounting the NFS mounts onto these volX 
mount points.

Therefore out fstab on a client machine looks like:

##client specific stuff##
...
melbourne-fs3:/server      /server    nfs     defaults  0 2
melbourne-fs3:/server/volumes/vol2      /server/volumes/vol2     nfs     
defaults  0 2
melbourne-fs3:/server/volumes/vol1      /server/volumes/vol1     nfs     
defaults  0 2
melbourne-fs3:/server/volumes/vol0      /server/volumes/vol0     nfs     
defaults  0 2


The fstab looks a little confusing with all the '/server/volumes/'  but 
just remember that the
'melbourne-fs3:/server/volumes/volx' are where physcal disk partitions 
have been mounted on the
server  and the '/server/volumes/volx' mount points are mounting those 
same physical patitions on 
the Linux client machines via NFS.

We use SuSE 9.2 Professional for Clients and Server.

Hope this is of value to you,

Regards,
David

   




Murray Trainer wrote:

>Hi All,
>
>We mount /home on our front end Linux machines via NFS from a backend
>Linux NFS file server.  This is nice and simple and reliable so far.  We
>want our user's to be able to access other shares but make them appear
>under their home directory, eg mount remote_share under
>/home/username/Shares/remote_share.  We could use automount or pam_mount
>to do the mounting when the user logs in.  But the problem is 
>that, unless there is some trick or new feature I am unaware of, NFS
>doesn't appear to be able to mount remote filesystems under these NFS
>home directories on the front-end Linux NFS client machine.  
>
>Mounting the remote filesystems elsewhere on the server and using
>symbolic links to point to make them appear to be under the user's home
>directory appears to be the only solution.  If anyone knows of a better
>way to achieve this I would greatly appreciate hearing about it.  If we
>go the symbolic links way, automating the process of creating the mounts
>and the symbolic links appears to be messy.  It was also suggested to me
>that I use the mount with the --bind option but I can't see how this
>would allow me to achieve mounts under the home directory.  Automount
>may be another option but I not that familiar with it.
>
>Does anyone have any suggestions on how best to implement a solution for
>the above situation?
>
>Thanks
>
>Murray
>
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by: NEC IT Guy Games.
>Get your fingers limbered up and give it your best shot. 4 great events, 4
>opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
>win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>  
>



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
