From: "Felipe Contreras" <felipe.contreras@gmail.com>
Subject: Map to different uid/gid
Date: Tue, 9 May 2006 17:04:21 -0500
Message-ID: <94a0d4530605091504y388d2938jcfb45ea627a7d7a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdaJf-0004zZ-Gv
	for nfs@lists.sourceforge.net; Tue, 09 May 2006 15:04:27 -0700
Received: from py-out-1112.google.com ([64.233.166.177])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FdaJe-0003z6-47
	for nfs@lists.sourceforge.net; Tue, 09 May 2006 15:04:27 -0700
Received: by py-out-1112.google.com with SMTP id x31so839835pye
        for <nfs@lists.sourceforge.net>; Tue, 09 May 2006 15:04:21 -0700 (PDT)
To: NFS <nfs@lists.sourceforge.net>
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

Hi everybody,

I have searched in several places and asked people, and I haven't
found if it's possible to map to a different uid/gid.

Let's say locally I'm uid 500 and gid 500 but I want to mount a NFS
share and be able to act as if I were uid 1000 gid 1000 (My user on
the server), that way I don't have to change anything in my box.

Is that possible?

--
Felipe Contreras


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
