From: Jan Hudec <bulb@ucw.cz>
Subject: Re: Unable to kill processes in D-state
Date: Sun, 6 Oct 2002 19:43:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021006174336.GC17170@vagabond>
References: <20021005182740.GC16200@vagabond> <20021005235614.GC25827@stud.ntnu.no> <20021006021802.GA31878@pegasys.ws> <1033871869.1247.4397.camel@phantasy> <20021006024902.GB31878@pegasys.ws> <20021006105917.GB13046@stud.ntnu.no> <20021006122415.GE31878@pegasys.ws> <20021006143636.GA30441@stud.ntnu.no> <20021006164228.GB17170@vagabond> <20021006170932.GA23134@stud.ntnu.no>
Reply-To: Jan Hudec <bulb@vagabond.cybernet.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Hudec <bulb@ucw.cz>, jw schultz <jw@pegasys.ws>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bohnice.netroute.lam.cz ([212.71.169.62] helo=vagabond.cybernet.cz)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yFRa-0006in-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Oct 2002 10:43:54 -0700
To: linux-kernel@vger.kernel.org
In-Reply-To: <20021006170932.GA23134@stud.ntnu.no>
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

On Sun, Oct 06, 2002 at 07:09:32PM +0200, Thomas Lang?s wrote:
> Jan Hudec:
> > If the shares were successfuly reloaded, then the processes should wake
> > up. If they don't, it's a bug in NFS.
> 
> They never wake up, and it happens every time.
> 
> > Try to reproduce it (ie. reboot some machine, let it start everything
> > and then restart the autofsd and see if processes lock up) and then talk
> > to NFS maintainers about that.
> 
> As I said above, it happens every time we encounter this, ie. it's a bug
> that easy to reproduce (since I added nfs@lists.sourceforge.net to the
> CC-list, I'm going to write some of what's already said in this thread).
> 
> Problem:
> Processes entering D-state is unkillable. We have a problem with this 
> everytime we restart autofs (which automounts quite a few NFS-shares
> on campus), ie. on our samba-boxes smbd hangs forever after this
> (in D-state). Samba still works, it's just that all the D-state processes
> is unkillable and will remain that way untill we reboot the computer.
> Every D-state process increases the load on the machine, and one of our
> 2-CPU intel-boxes currently remains at 430 (which extremly high for such
> a box).
> 
> Solution:
> ? :)

You should probably provide detailed info on your setup (computers,
kernel versions, automounter version etc. - as SubmitingBugs in kernel
source suggests). (And maybe change subject to start with NFS PROBLEM,
so more NFS people notice.)

-------------------------------------------------------------------------------
						 Jan 'Bulb' Hudec <bulb@ucw.cz>


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
