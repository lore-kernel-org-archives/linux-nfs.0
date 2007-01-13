From: "wim appermans" <wim.lists@gmail.com>
Subject: Re: NFS3ERR_ACCES on getattribute
Date: Sat, 13 Jan 2007 01:24:52 +0100
Message-ID: <e468ef330701121624m27977b64jf1c7b8a2d13bf842@mail.gmail.com>
References: <e468ef330701101552n2e2ee36w47497e19dd9cf136@mail.gmail.com>
	<1168528905.6170.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H5Whb-0000vK-AP
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 16:24:55 -0800
Received: from an-out-0708.google.com ([209.85.132.251])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H5Whb-0000Tq-LZ
	for nfs@lists.sourceforge.net; Fri, 12 Jan 2007 16:24:57 -0800
Received: by an-out-0708.google.com with SMTP id d40so1121074and
	for <nfs@lists.sourceforge.net>; Fri, 12 Jan 2007 16:24:53 -0800 (PST)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1168528905.6170.27.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

Sorry I was a bit short on information.
Both client and server are running the ubuntu edgy kernel (2.6.17)

Meanwhile, I came accross this:
  https://launchpad.net/ubuntu/+source/linux-source-2.6.17/+bug/62308

Seems to be the same as I'm seeing.
I tried exporting with no_subtree_check, and it looks like this solves
the problem. It should be fixed in 2.6.18.

Thanks for your time,

Wim


https://launchpad.net/ubuntu/+source/linux-source-2.6.17/+bug/62308

On 1/11/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2007-01-11 at 00:52 +0100, wim appermans wrote:
> > Hi,
> >
> > I'm struggeling for a while now with nfs, and I don't really know how
> > to go forward anymore, so I was hoping someone over here could give me
> > some ideas...
> >
> > The setup is rather simple: one linux machine, acting running an nfs
> > server and a few linux clients. Athentication and stuff is done via
> > ldap
> >
> > What we're seeing is that on the clients, files seem to be randomly
> > inaccessable.
> > I'm mounting /home. and if I do someting like 'find .' in my homedir,
> > nfs will give randomly errors on files that are not accessible. The
> > thing is, the files it list have the right permissions. And if I run
> > the command a few times in a row, the files it complains about are not
> > the same. It also gives 'stale filehandler' errors.
> >
> > I got a small test now that fails consistently. It goes like this:
> >
> > * mount the nfs drive
> > * do an ls of a specific directory (this is a dir that I saw turning
> > up
> > a lot in the 'find' errors)
> > * ls works correctly
> > * do an ls again
> > * now ls fails and gives me 'access denied'
> >
> > If I unmount and repeat: same behaviour
> >
> > I made a trace with wireshark, and this is what I get:
> >
> >   V3 NULL Call (Reply In 42)
> >   V3 NULL Reply (Call In 40)
> >   V3 NULL Call (Reply In 82)
> >   V3 NULL Reply (Call In 80)
> >   V3 FSINFO Call (Reply In 85), FH:0x0493dc00
> >   V3 FSINFO Reply (Call In 84)
> >   V3 GETATTR Call (Reply In 87), FH:0x0493dc00
> >   V3 GETATTR Reply (Call In 86)  Directory mode:2775 uid:0 gid:50
> >   V3 ACCESS Call (Reply In 92), FH:0x0493dc00
> >   V3 ACCESS Reply (Call In 91)
> >   V3 LOOKUP Call (Reply In 95), DH:0x0493dc00/chrisr
> >   V3 LOOKUP Reply (Call In 94), FH:0x086861a2
> >   V3 ACCESS Call (Reply In 97), FH:0x086861a2
> >   V3 ACCESS Reply (Call In 96)
> >   V3 LOOKUP Call (Reply In 99), DH:0x086861a2/.evolution
> >   V3 LOOKUP Reply (Call In 98), FH:0x446a61a2
> >   V3 GETATTR Call (Reply In 101), FH:0x446a61a2
> >   V3 GETATTR Reply (Call In 100)  Directory mode:0777 uid:2000
> > gid:2000
> >   V3 ACCESS Call (Reply In 103), FH:0x446a61a2
> >   V3 ACCESS Reply (Call In 102)
> >   V3 READDIRPLUS Call (Reply In 106), FH:0x446a61a2
> >   V3 READDIRPLUS Reply (Call In 104) . .. addressbook cache calendar
> > mail memos signatures tasks camel-cert.db cert8.db key3.db secmod.db
> >   V3 GETATTR Call (Reply In 109), FH:0x446a61a2
> >   V3 GETATTR Reply (Call In 108) Error:NFS3ERR_ACCES
> >
> > So if I understand correclty (I'm new to nfs. bear with me), The
> > client
> > first gets the filehandler of the directory of which I do an ls, and
> > then does a READDIRPLUS. All is fine so far.
> > When I do the second ls, it does a GETATTR, which gets an
> > NFS3ERR_ACCES
> > back.
> >
> > So there are a few things I don't understand.
> >
> > * why does a GETATTR goes well the first time, and gets an error the
> > second time
> > * why is the second GETATTR done in the first place, isn't this
> > supposed to be cached? (I remeber reading something about attribute
> > caching somewhere, but I'm not sure it has anything to do with this)
> > * what does the NFS3ERR_ACCES mean. Can it have something to do with
> > file locking?
> >
> > Another thing I should probably tell is that the same dirs are also
> > shared with CIFS. Can there be some kind of conflict between CIFS and
> > NFS
> >
> > And if it has something to do with locking, is there a way to find out
> > who is locking what and why?
> > (some pointers to a comprehensive description of the whole lcoking
> > thing would also be appreciated. this is all rather obscure to me)
> >
> > Can the LDAP setup have anything to do with it? I think not, since nfs
> > just compares gid and uid numbers and doesn't have to do a lookup of
> > any group or user names, but maybe I'm missing something.
> >
> > Any help would be greatly appreciated. Also pointers on how to get
> > more
> > information on what's happening on the NFS server side or what there
> > is
> > still to do to get a better understanding on what is going on..
> >
> > Thanks,
> >
> > Wim
>
> Mind telling us a bit about which kernels you are using, and what
> your /etc/exports looks like? A little bit of info on how the
> filesystems you are exporting are organised might help too...
>
> Cheers,
>   Trond
>
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
