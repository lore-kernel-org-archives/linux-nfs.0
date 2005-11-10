From: Neil Horman <nhorman@redhat.com>
Subject: Re: NFS inconsistencies experienced between server and client.
Date: Thu, 10 Nov 2005 10:16:38 -0500
Message-ID: <20051110151638.GD1391@hmsendeavour.rdu.redhat.com>
References: <51E1B8DFD9EE6747889DB802751770B906FE7E@S229378RGEW08.apptix-01.savvis.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EaEAU-00006X-6C
	for nfs@lists.sourceforge.net; Thu, 10 Nov 2005 07:16:50 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EaEAS-0000sC-ON
	for nfs@lists.sourceforge.net; Thu, 10 Nov 2005 07:16:50 -0800
To: "Thomas, Dave" <Dave.Thomas@savvis.net>
In-Reply-To: <51E1B8DFD9EE6747889DB802751770B906FE7E@S229378RGEW08.apptix-01.savvis.net>
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

On Thu, Nov 10, 2005 at 12:42:54PM -0000, Thomas, Dave wrote:
> Hi,
> 
>  
> 
> I currently a web site consisting of one NFS server and 2 clients
> running RedHat AS3.0 (kernel 2.4.21-9.0.1.ELsmp)
> 
Have you tried this with the latest RHEL3 kernel?  I remember a simmilar problem
being addressed some time ago.
Neil

>  
> 
> Clients run:-
> 
> Apache/2.0.52
> 
> jakarta-tomcat-5.5.4
> 
> nfs-utils-1.0.6-33EL
> 
>  
> 
> Server runs:-
> 
> mysql  Ver 14.7 Distrib 4.1.13, for pc-linux-gnu (i686) using readline
> 4.3
> 
> nfs-utils-1.0.6-33EL
> 
>  
> 
> The server shares out a directory /data01/www, mounted as /www on the
> clients, which contains the DocumentRoot used by apache.
> 
>  
> 
> New content is uploaded to the server at /data01/www, several times a
> day.
> 
>  
> 
> I am seeing inconsistencies between some files on the server, and the
> same files on the client, index.shtml files in particular.
> 
> When I run a checksum on certain files on the clients and server,
> different results are obtained. The checksums, and the files, only
> become identical if the file is deleted before being uploaded onto the
> server, but this is not an option.
> 
> If the file is not deleted, before being uploaded, they remain different
> indefinitely. 
> 
>  
> 
> The filesystem is exported with the options (rw,async), and mounted with
> following (rsize=8192,wsize=8192,timeo=15,rw,hard,intr).
> 
> We have tested by changing several mount options, including:-
> 
> Server export with ro, client mount with ro, client mount with noac. We
> have increased the number of nfs threads on the server from 8 to 16.
> 
>  
> 
> But the problem is still being experienced, and is becoming a critical
> issue, as the website shows different data, depending upon which client
> you connect to.
> 
>  
> 
>  
> 
> Any thoughts would be welcome.
> 
>  
> 
> Thanks,
> 
>  
> 
> Dave.
> 
>  
> 

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
