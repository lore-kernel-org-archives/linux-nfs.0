From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [PATCH] nfs-utils: fix for statd with the -n option
Date: Tue, 16 Nov 2004 16:54:19 -0800
Message-ID: <OF18FAD09E.05033830-ON88256F4F.00041A92-88256F4F.0004F95E@us.ibm.com>
References: <OFE26DDBB8.4886C7F8-ON88256F4E.006A4FC9-88256F4E.0074DB85@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CUE7z-0007Jf-7n
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 16:56:55 -0800
Received: from e4.ny.us.ibm.com ([32.97.182.104])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CUE7x-0000th-D1
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 16:56:55 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAH0uqKv097772
	for <nfs@lists.sourceforge.net>; Tue, 16 Nov 2004 19:56:52 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAH0upJZ214280
	for <nfs@lists.sourceforge.net>; Tue, 16 Nov 2004 19:56:51 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAH0upxX025178
	for <nfs@lists.sourceforge.net>; Tue, 16 Nov 2004 19:56:51 -0500
In-Reply-To: <OFE26DDBB8.4886C7F8-ON88256F4E.006A4FC9-88256F4E.0074DB85@us.ibm.com>
To: okir@suse.de
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

Hi Olaf

Can you (or if you prefer I can) add the statd option -n to sm-notify. Once
the option is available the code needs
to bind to that address so the client get the notification from the IP
address that it is monitoring in the case of multiple IP address.
The following is my fix for statd to do the same.

Thanks, Marc.

Marc Eshel <eshel@almaden.ibm.com> wrote on 11/16/2004 01:16:23 PM:

> Hi Neil,

> Here is another fix for statd, I hope that you are the right person to
> handle this request patch nfs-utils. This fix will send the notify msg
> using the IP address specified with the -n option to statd. This will fix
> the problem that statd in the kernel has of not being able to convert
> mon_name to an IP address (no gethostbyname() in the kernel) and any
other
> clients that ignore the mon_name in the notify msg and use the source IP
> address from the RPC request.

>
> --- rmtcall.c.orig      2004-11-16 11:02:59.374758344 -0800
> +++ rmtcall.c     2004-11-16 10:42:03.901619272 -0800
> @@ -65,6 +65,16 @@ statd_get_socket(int port)
> memset(&sin, 0, sizeof(sin));
> sin.sin_family = AF_INET;
> sin.sin_port = port;
> +     /*
> +      * If a local hostname is given (-n option to statd), bind to the
> address
> +      * specified. This is required to support clients that ignore the
> mon_name in
> +      * the statd protocol but use the source address from the request
> packet.
> +      */
> +     if (MY_NAME) {
> +           struct hostent *hp = gethostbyname(MY_NAME);
> +           if (hp)
> +                 sin.sin_addr = *(struct in_addr *) hp->h_addr;
> +     }
> if (bindresvport(sockfd, &sin) < 0) {
> dprintf(N_WARNING,
> "process_hosts: can't bind to reserved port\n");

>
> -------------------------------------------------------
> This SF.Net email is sponsored by: InterSystems CACHE
> FREE OODBMS DOWNLOAD - A multidimensional database that combines
> robust object and relational technologies, making it a perfect match
> for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
