From: ashutosh.varshney@st.com
Subject: RE: Problem : Linux - SOlaris NFS
Date: Fri, 20 Sep 2002 09:09:49 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <H0000475046f3994.1032492936.dlx99.dlh.st.com@MHS>
References: <6440EA1A6AA1D5118C6900902745938E07D54E8E@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, ashutosh.varshney@st.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from beta.dmz-eu.st.com ([164.129.1.35])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sEeP-0005mI-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 20:40:17 -0700
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D54E8E@black.eng.netapp.com>
To: Charles.Lever@netapp.com
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

Hi
Yes ..we are using nfs over udp. . NFS server is Solaris 8 (with default
r/wsize=32Kb) and NFS Client is Red Hat Linux 7.3 ( kernel version
2.4.18-3)..
thanks for ur response
ashutosh

> please verify your configuration for me:
> 
> you are using NFS over UDP with 32K r/wsize?
> your Linux clients run a 2.4 kernel, probably 2.4.18?
> 
> > > We had a lot of SUN machines and just installed few linux 
> > machines.We
> > > have all our licenses/Softwares of Solaris m/cs( NIS also 
> > on Solaris).But
> > > when we access the things from linux client..network 
> > chokes..all things
> > > hang..then we reboot the linux ..and set the rsize & wsize 
> > to 8K and now
> > > things work fine..
> > > Can any one puts lights why this all happen ..where is the 
> > problem.. in
> > > linux or solairs.
> > > Any site referneces for this customization..
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
