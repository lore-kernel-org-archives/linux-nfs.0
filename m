From: "xiong yi" <xiongyicn@hotmail.com>
Subject: Can NFS synchronize the file of different hosts automatically?
Date: Fri, 09 Jul 2004 17:24:01 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY15-F37wSpJMDsl5I0001314b@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Birc1-0001JN-LB
	for nfs@lists.sourceforge.net; Fri, 09 Jul 2004 02:24:09 -0700
Received: from bay15-f37.bay15.hotmail.com ([65.54.185.37] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Birc1-00006u-AO
	for nfs@lists.sourceforge.net; Fri, 09 Jul 2004 02:24:09 -0700
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

  Hello,everyone!
    I face a task recently,that is when the files of server change or 
update,the corresponding files of client can change or update automatically 
without any delay.For example,the device file of server changes when the 
device's state changes.A simple example is about the mouse's device 
file.When I move the server's mouse,the mouse device file of server change 
automatically. I want the client can get the server's mouse device file and 
 can change and update automatically just as on the server when I move the 
server's mouse.
I am considering NFS for the solution,but I don't know NFS whether can 
achieve the task or not because of my lacking of experience about this.If 
NFS do,how to configure?
    I am looking forward to get your reply so much.And thank you very much.

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
