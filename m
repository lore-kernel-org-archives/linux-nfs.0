From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: NFS over TCP -- configuring server for
Date: Mon, 19 Jan 2004 13:16:13 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401191316.13742.bernd-schubert@web.de>
References: <5.0.2.1.0.20040118212546.057a7080@pop.erols.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiYKN-0003bn-JB
	for nfs@lists.sourceforge.net; Mon, 19 Jan 2004 04:16:23 -0800
Received: from smtp04.web.de ([217.72.192.208] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AiYKN-0008V7-6H
	for nfs@lists.sourceforge.net; Mon, 19 Jan 2004 04:16:23 -0800
Received: from [80.140.18.32] (helo=192.168.6.2)
	by smtp.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.99 #566)
	id 1AiYKE-0001m9-00
	for nfs@lists.sourceforge.net; Mon, 19 Jan 2004 13:16:15 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <5.0.2.1.0.20040118212546.057a7080@pop.erols.com>
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

On Monday 19 January 2004 03:33, Paul D. Bain wrote:
>          I need to know how to have my NFS services carried over TCP, not
> UDP. From postings to the Linux-NFS mailing list, I understand that I must
> recompile my server's kernel (and the client's kernel, too?) and add the
> parameter "tcp" to the file /etc/fstab on the client. What else do I need
> to do? For example, must I add anything to the file /etc/exports on the
> server?
>

A server kernel with tcp-support and specifying tcp as mount option on the 
client side is enough. So you don't need to do anything else, just try it 
yourself ;)

Cheers, Bernd


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
