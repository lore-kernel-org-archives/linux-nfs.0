From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: Problem : Linux - SOlaris NFS
Date: Thu, 19 Sep 2002 10:23:04 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D8A07F8.AD875BE9@attbi.com>
References: <H00004750469f74b.1032248298.dlx99.dlh.st.com@MHS>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17s4wg-00067l-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Sep 2002 10:18:30 -0700
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

Since Solaris defaults to 32K transfer sizes, and the client may be 
taking its cues from the server, the 32K size might be too much for
the client NIC.  If this is true, you should be able to correct 
things simply by remounting with 8K rsize & wsize.  If the reboot
is required, there may be more going on.

One thing; I've got Solaris 8 on Intel installed on my test machine
and did not run across any problems when I was running some tests
earlier this summer, using a 2.4.18 client.

Regards -

Tom

ashutosh.varshney@st.com wrote:
> 
> Hi
> 
> We had a lot of SUN machines and just installed few linux machines.We
> have all our licenses/Softwares of Solaris m/cs( NIS also on Solaris).But
> when we access the things from linux client..network chokes..all things
> hang..then we reboot the linux ..and set the rsize & wsize to 8K and now
> things work fine..
> Can any one puts lights why this all happen ..where is the problem.. in
> linux or solairs.
> Any site referneces for this customization..
> 
> thanks in advance
> 
> Ashutosh
> 
> -------------------------------------------------------
> Sponsored by: AMD - Your access to the experts on Hammer Technology!
> Open Source & Linux Developers, register now for the AMD Developer
> Symposium. Code: EX8664 http://www.developwithamd.com/developerlab
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

--
----------------------------------------------------------------------
Tom McNeal            trmcneal@attbi.com          (650)906-0761 (cell) 
----------------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
