From: David Dougall <davidd@et.byu.edu>
Subject: Re: Help diagnosing bizarre NFS problem
Date: Mon, 24 Jan 2005 11:17:34 -0700 (MST)
Message-ID: <Pine.LNX.4.58.0501241116080.23996@lewis.et.byu.edu>
References: <BA594DD2-65DA-11D9-B0EB-000A95A07AB8@valuecommerce.co.jp>
 <731336CA-6DE6-11D9-8B4D-000A95A07AB8@valuecommerce.co.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ct8mc-0000Fq-FD
	for nfs@lists.sourceforge.net; Mon, 24 Jan 2005 10:17:50 -0800
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ct8mb-0006FO-RZ
	for nfs@lists.sourceforge.net; Mon, 24 Jan 2005 10:17:50 -0800
To: Nathan Ollerenshaw <nathan@valuecommerce.co.jp>
In-Reply-To: <731336CA-6DE6-11D9-8B4D-000A95A07AB8@valuecommerce.co.jp>
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

In that past when I get that error message and dropping the rsize/wsize
fixes it, it is directly related to a network problem.
buggy network driver
speed mismatch between client/server(tcp solves this usually)
flaky wiring/switch/etc
--David Dougall


On Mon, 24 Jan 2005, Nathan Ollerenshaw wrote:

> Hi folks,
>
> I posted this a couple of weeks ago, hoping someone could give us a
> clue.
>
> We've dropped back to UDP and 1024 wsize and rsize, which seems to have
> killed the problem for our webservers (yay) but also killed performance
> (boo).
>
> I'm wondering if any of you would have any insight as to why this would
> fix the problem, and what the root cause might be?
>
> Currently the vendor is blaming the network and the linux NFS client
> code for the issue; I need a better idea than just "its your
> network/linux os fault".
>
> Thanks,
>
> Nathan.
>
> ps. If this is completely the wrong place to ask about technical
> difficulties with the Linux NFS client stack please point me in the
> right direction. I kinda got no response from the last email so I'm
> assuming either a) nobody knows or b) nobody cares or c) I'm posting to
> the wrong list ;)
>
> On Jan 14, 2005, at 12:16 PM, Nathan Ollerenshaw wrote:
>
> > Hi All,
> >
> > I need some help diagnosing a bizarre problem that has been affecting
> > our NFS based system for the past 4 weeks or so. We've tried getting
> > help from our NAS vendor (EMC) and we've been trawling google (and
> > these list archives) and so far not found any real indication of what
> > the problem might be.
> >
> > Please, if you have any ideas of how to diagnose the problem, please
> > let us know.
> >
> > THE SETUP:
> >
> > We have an EMC NAS box, a Celerra, running DART (so they tell us, we
> > don't have access to it, so I have no idea whats going on in the
> > server side).
> >
> > We have a pair of foundry networks 48 port 10/100 switches providing a
> > switched network for the machines. There are 6 mail servers and 4 web
> > servers (soon to be 8) that mount a filesystem each from the NAS. We
> > have a filesystem for mail data (stored in Maildir format) and a
> > filesystem for web content. The webservers see about 20 million
> > requests a day, load balanced across all of them with a pair of
> > foundries.
> >
> > Mail is stored in the format of
> > /data/mail/xx/xx/domain/user@domain/Maildir/. Web is stored in the
> > format of /data/web/xx/xx/domain/ with directories under here for the
> > www docroot, cgi-bin, etc. Customers can upload their stuff with FTP,
> > and they can put cgis into the cgi-bin if they want. We have a wrapper
> > that runs the CGIs as the user's UID/GID in their cgi-bin.
> >
> > We have a box that runs a custom 'administration UI' that makes all
> > the changes to DNS files, apache configs, filesystem etc to provision
> > customer's websites/email etc. There is a box that is currently doing
> > a backup over the NFS (because the snapshots were misconfigured by me
> > on the NAS, ha ha). It takes about 12 hours to read all the data and
> > tar it up.
> >
> > All the client machines are recently patched Fedora Core 2 machines
> > running 2.6.9 (currently, we will probably try 2.6.10 in the near
> > future)
> >
> > THE PROBLEM:
> >
> > regularly, about once a day, at no specific time, each of the web
> > servers NFS mount will 'lock up'. This seems to manifest itself in one
> > of the deeper directories first, until it works its way down to the
> > actual mount point, at which time the machine basically is unable to
> > serve any traffic.
> >
> > When we log into the machine, we see:
> >
> > Jan  6 09:17:00 www4 kernel: nfs: server nfs not responding, still
> > trying
> > Jan  6 09:17:00 www4 kernel: nfs: server nfs not responding, still
> > trying
> > Jan  6 09:20:47 www4 kernel: nfs: server nfs not responding, still
> > trying
> >
> > Sometimes we will see a message like this:
> >
> > Dec 27 10:41:51 www2 kernel: nfs_statfs: statfs error = 512
> >
> > Messages such as this are also common:
> >
> > nfs_proc_symlink: lock/DGMDNP-042.txt_lock_lock already exists??
> >
> > Doing a tethereal at the time, we see stuff like this:
> >
> >  62.303877  10.128.1.11 -> 10.128.2.33  NFS V3 WRITE Reply (Call In
> > 27) Error:ERR_STALE
> >
> > Now, the "statfs error = 512" seems to be indicating that the NAS is
> > having a problem. But this isn't the case. I can at least check the
> > uptime of the EMC from the control panel UI that EMC provide (which
> > I'm not very happy with, but thats another saga you can ask me about
> > in private if your interested). The NAS itself is not rebooting. The
> > RPC services it provides are not going away either; I have a script
> > running on another machine that checks the services every second on
> > the server, and they have never even flinched. So I don't think its a
> > problem with the EMC crashing or whatnot.
> >
> > What IS interesting is that the www servers have this problem about
> > once or twice a day, each. The mailservers rarely have this problem.
> > The machine that does the backup never seems to have the problem.
> >
> > This issue is really doing my head in. If someone could tell me a way
> > of getting more information out of the clients to enable us to see
> > what is going on, that'd be awesome.
> >
> > We've tried using UDP, dropping the packet size, dropping back to the
> > latest vanilla 2.4.x kernel, everything we can think of. Nothing seems
> > to be helping right now.
> >
> > Our vendor is of course helping us, they have done tcp dumps on the
> > server side, done whatever diagnosis they can on their side and right
> > now they are saying its a client side issue, but they are unable to
> > provide any hard evidence either way.
> >
> > Vendor currently says:
> >
> >> Anyway, at the present moment, we can say, we haven't finished
> >> analyzing
> >> network traces completely, however, we found some strange point in the
> >> network trace. As per customer, customer uses the file locking over
> >> NFS.
> >> Indeed, we can see NLM protocol in the network trace. Some of
> >> clients keep
> >> sending NLM_UNLOCK for some of files without sending NLM_LOCK.
> >> Generally, if
> >> using NLM, the sequence is NLM_LOCK call for relevant file is
> >> executed from
> >> NFS client and then NLM_UNLOCK for that file is executed from NFS
> >> client.
> >> Thus, the file locking will be completed. We can't see any corresponds
> >> between LOCK and UNLOCK. From the beginning of the trace, some of
> >> client
> >> keep sending only NLM_UNLOCK. That is very strange.
> >
> > There is nothing in the RFC that says that NLM_LOCK and NLM_UNLOCK
> > counts must be equal. Additionally, the extra NLM_UNLOCK messages
> > simply indicates that there was a failure to lock or unlock a file.
> > From what I understand, this technique is used in crash recovery,
> > which seems to indicate SOMETHING is crashing, if not the EMC, what?
> > How can I prove it either way?
> >
> > If anyone on this list can suggest anything obvious or not, it will be
> > appreciated :)
> >
> > Regards,
> >
> > Nathan.
> >
> > --
> > "It is change, continuing change, inevitable change, that is
> >  the dominant factor in society today. No sensible decision can
> >  be made any longer without taking into account not only the
> >  world as it is, but the world as it will be." - Isaac Asimov
> >
> >
> >
> > -------------------------------------------------------
> > The SF.Net email is sponsored by: Beat the post-holiday blues
> > Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
> > It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
>
> --
> "It is change, continuing change, inevitable change, that is
>   the dominant factor in society today. No sensible decision can
>   be made any longer without taking into account not only the
>   world as it is, but the world as it will be." - Isaac Asimov
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
> Tool for open source databases. Create drag-&-drop reports. Save time
> by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
> Download a FREE copy at http://www.intelliview.com/go/osdn_nl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
