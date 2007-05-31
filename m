From: "robin ros" <linux.robin@gmail.com>
Subject: Received erroneous SM_UNMON request
Date: Thu, 31 May 2007 15:06:08 -0600
Message-ID: <fc0152210705311406w1cc94cb8yf0c1ea7274befedd@mail.gmail.com>
References: <fc0152210705311118i28657a97v47dc9c3129849367@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtrqT-0005WH-4H
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:06:09 -0700
Received: from an-out-0708.google.com ([209.85.132.246])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HtrqU-00032D-VA
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:06:12 -0700
Received: by an-out-0708.google.com with SMTP id b38so133866ana
	for <nfs@lists.sourceforge.net>; Thu, 31 May 2007 14:06:09 -0700 (PDT)
In-Reply-To: <fc0152210705311118i28657a97v47dc9c3129849367@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

hi everyone,

i think this is a old post, but i cannot resolv this, in my syslog i
found this messages in my debian sarge server, with nfs-common 1.0.6-3
and nfs-kernel-server 1.0.6-3 and nis 3.13-2:

May 31 11:55:40 servidor rpc.statd[3214]: Received erroneous SM_UNMON
request from xxx.xxx.xxx.xxx for 192.168.1.16
May 31 11:59:51 servidor rpc.statd[3214]: Received erroneous SM_UNMON
request from xxx.xxx.xxx.xxx for 192.168.1.138
May 31 12:00:51 servidor rpc.statd[3214]: Received erroneous SM_UNMON
request from xxx.xxx.xxx.xxx for 192.168.1.16
May 31 12:02:52 servidor rpc.statd[3214]: Received erroneous SM_UNMON
request from xxx.xxx.xxx.xxx for 192.168.1.155

in my fstab is like this for nfs mount.

xxx.xxx.xxx.xxx:/home /home nfs rw,exec,rsize=8192,wsize=8192,intr, 0 0

what can i do to resolv this error??

thanks for you help

robin

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
