From: "xiong yi" <xiongyicn@hotmail.com>
Subject: some stranges about device files in the NFS system
Date: Tue, 13 Jul 2004 01:37:34 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY15-F17p0m67QJYyF0004cf6b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bk4ks-0001e2-Cv
	for nfs@lists.sourceforge.net; Mon, 12 Jul 2004 10:38:18 -0700
Received: from bay15-f17.bay15.hotmail.com ([65.54.185.17] helo=hotmail.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bk4ks-0005Tk-2Z
	for nfs@lists.sourceforge.net; Mon, 12 Jul 2004 10:38:18 -0700
To: nfs@lists.sourceforge.net
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

Hello everyone! 

I am using NFS to synchoronize the some file between server and client.But 
for device files ,some stranges happen,and I can't get the reason. The 
network environment has no problem becanse of the localhost as a server and 
a client at the same time.Whem I mount the server's device file :/dev/input 
to the client: /mnt/net,everything is OK and no exception happened. And the 
file "mice" in the /dev/input is the mouse's devcie file of server.And I 
execute the command "cat /dev/input/mice" to display the file of server.At 
the same time,I move my mouse,the display changed becanse the mouse's state 
was changing.But when I executed the command "cat /mnt/net/mice" to display 
the file of client, the process exit without any infomation.I don't know 
why. I get the states of the file "/dev/input/mice" of server and the file 
"mnt/net/mice" of client,the information is as follows: 

the file state of client: [root@xiongyi net]# stat ./mice   File: ‘./mice’
 Size: 0               Blocks: 0          IO Block: 8192   Character Device 
Device: ah/10d  Inode: 162551      Links: 1     Device type: d,3f Access: 
(0600/crw-------)  Uid: (    0/    root)   Gid: (    0/    root) Access: 
2003-01-30 18:24:35.000000000 +0800 Modify: 2003-01-30 18:24:35.000000000 
+0800 Change: 2004-05-03 00:59:19.000000000 +0800 


the file state of server: [root@xiongyi net]# stat /dev/input/mice File: ‘
/dev/input/mice’ Size: 0               Blocks: 0          IO Block: 4096   
Character Device Device: 307h/775d       Inode: 162551      Links: 1     
Device type: d,3f Access: (0600/crw-------)  Uid: (    0/    root)   Gid: ( 
   0/    root) Access: 2003-01-30 18:24:35.000000000 +0800 Modify: 
2003-01-30 18:24:35.000000000 +0800 Change: 2004-05-03 00:59:19.000000000 
+0800 

I can't get the reason why execute "cat divicefile" in the client  did NOT 
work.And whether can the device file synchronize.  I am a new about NFS,I 
wish your help and hints.

_________________________________________________________________
享用世界上最大的电子邮件系统— MSN Hotmail。  http://www.hotmail.com  



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
