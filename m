From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Problem : Linux - SOlaris NFS
Date: Thu, 19 Sep 2002 13:00:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D54E8E@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17s7Ta-000170-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 13:00:38 -0700
To: ashutosh.varshney@st.com
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

please verify your configuration for me:

you are using NFS over UDP with 32K r/wsize?
your Linux clients run a 2.4 kernel, probably 2.4.18?

> > We had a lot of SUN machines and just installed few linux 
> machines.We
> > have all our licenses/Softwares of Solaris m/cs( NIS also 
> on Solaris).But
> > when we access the things from linux client..network 
> chokes..all things
> > hang..then we reboot the linux ..and set the rsize & wsize 
> to 8K and now
> > things work fine..
> > Can any one puts lights why this all happen ..where is the 
> problem.. in
> > linux or solairs.
> > Any site referneces for this customization..


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
