From: Steve Dickson <SteveD@redhat.com>
Subject: Re: TCP: Server unavailable
Date: Fri, 24 Oct 2003 11:33:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F994666.6030708@RedHat.com>
References: <5C4853FD4EFB164A8F4FE5AFF1306321037B6D@MSGBOSCLD2WIN.DMN1.FMR.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ADGIa-0003sE-00
	for <nfs@lists.sourceforge.net>; Fri, 24 Oct 2003 21:45:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AD3wk-0000nj-D0
	for nfs@lists.sourceforge.net; Fri, 24 Oct 2003 08:33:50 -0700
To: "Chimento, Douglas" <Douglas.Chimento@FMR.COM>
In-Reply-To: <5C4853FD4EFB164A8F4FE5AFF1306321037B6D@MSGBOSCLD2WIN.DMN1.FMR.COM>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



Chimento, Douglas wrote:

>Hello,
>	I am trying to setup a Linux client (RH9) to use tcp with nfs.
>However 
>	there server (also RH9) replies with 
>"nfs server reported service unavailable: Address already in use"
>  
>
TCP support on the server side is not configured in by default.

Note the lack of
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
entries in the rpcinfo output (assuming rpcinfo -p was done on the server)

SteveD.



-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
