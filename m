From: Jean-Eric Cuendet <jean-eric.cuendet@linkvest.com>
Subject: Re: Striping Support
Date: Mon, 09 Sep 2002 15:51:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D7CA76C.2050908@linkvest.com>
References: <CCEEJJECKDHNCGDIAEPCGEAJCAAA.mahesh@calsoftinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
To: Mahesh <mahesh@calsoftinc.com>,  nfs@sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

INMHO, that's not NFS responsibility.
Use MD or LVM devices to do that. Or hardware if you have money.
As soon as you speak of RAID (hard or soft), striping can be done (In 
quite all cases).
A good start: the Soft-EAID-Howto from www.linuxdoc.org
Or buy an Adaptec card (2100 or 2110)

Hope this helps.
-jec

Mahesh wrote:

>Hi
>
>	Does anyone know where i can get the source code for an NFS implementation
>that supports striping of files across multiple storage media or mutiple
>partition servers.
>
>Regards
>Mahesh Unnikrishnan
>(mahesh@calsoftinc.com)
>
>
>
>-------------------------------------------------------
>This sf.net email is sponsored by: OSDN - Tired of that same old
>cell phone?  Get a new here for FREE!
>https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>  
>

-- 
Jean-Eric Cuendet
Linkvest SA
Av des Baumettes 19, 1020 Renens Switzerland
Tel +41 21 632 9043  Fax +41 21 632 9090
E-mail: jean-eric.cuendet@linkvest.com
http://www.linkvest.com
--------------------------------------------------------






-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
