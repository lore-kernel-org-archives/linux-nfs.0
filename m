From: Han <han@mijncomputer.nl>
Subject: Re: pf: to scrub or not to scrub?
Date: Sun, 28 Jul 2002 01:24:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020727232451.GG26763@han.myip.org>
References: <Pine.GSO.4.33.0207241828330.586-100000@loogie.intranet.csupomona.edu> <20020725094904.GE8969@skywalker.bsws.de> <20020725183112.GA4708@esme.xs4all.nl> <20020725190243.GB8076@w4g.org>
Reply-To: misc@openbsd.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
In-Reply-To: <20020725190243.GB8076@w4g.org>
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

Hi,

I  run  an  OpenBSD  (current)  nfs  server  with  a  linux  nfs  client
(2.4.19-rc3-ac3) and if I turn on  the  scrub  feature  (reassemble  all
fragments)  of  the  OpenBSD  firewall  I  get  into  trouble  with  the
nfs-client not being able anymore to connect. Perhaps this is something
that can be improved in the nfs code. This is not  urgent  since  I  can
tell the firewall to only pay attention to fragments from  the  external
interface.

If I can be of  any  assistance  please  let  me  know,  but  I  am  not
subscribed to the list.

Here is the refering part of the man-page.

  http://www.openbsd.org/cgi-bin/man.cgi?query=pf.conf&apropos=0&sektion=0&manpath=OpenBSD+Current&arch=i386&format=html#NORMALIZATION


Mike Frantzen (frantzen@w4g.org) wrote:
>
> > Unless - dare I say it  -  you  have  to  deal  with  Linux  NFS  in
> > conjunction with that pf firewall, in which case NFS won't work when
> > scrub is used. That just bit me the other day  (Linux  2.2.x  client
> > <-> pf <-> Linux 2.4.x server[0]). It's mentioned in the archives of
> > this list and the conclusion at the  time  was  that  it's  a  Linux
> > problem[1]. Interesting enough I had the same problem with  a  Linux
> > 2.4.x client and an OpenBSD 3.1 server. Both issues vanished after I
> > removed scrub from the rules. Just  something  to  be  aware  of,  I
> > think.
> 
> IIRC Linux's NFS server set DF and MF at the same time (Don't Fragment
> and More Fragments) which leads to an ambiguity in the interpretation.
> At the moment, I can't think of anything really bad that could come of
> the ambiguity.  But SCRUB's job is to resolve ambiguities or drop them
> if it couldn't be resolved somehow.



Groetjes, Han.
-- 
       ::.     +------------------------------------------------------+
(\./)  .-""-.  | normous cats on the dinette table, etc. -- Dave      |
 `\'-'`      \ | Barry, "The Taming of the Screw"                     |
   '.___,_^__/ +------------------------------------------------------+


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
