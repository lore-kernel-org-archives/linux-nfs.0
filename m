From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: more SMP issues
Date: Wed, 27 Mar 2002 22:58:51 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <007c01c1d615$4232fe60$2e060e09@beavis>
References: <200203261934.NAA25602@popmail.austin.ibm.com><15521.13735.293466.799706@notabene.cse.unsw.edu.au><200203271649.KAA37894@popmail.austin.ibm.com> <15522.38550.557032.473224@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Received: from mg03.austin.ibm.com ([192.35.232.20])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qRwL-0002l4-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 20:55:09 -0800
Received: from austin.ibm.com (netmail1.austin.ibm.com [9.3.7.138])
	by mg03.austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id WAA24758
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 22:51:18 -0600
Received: from popmail.austin.ibm.com (popmail.austin.ibm.com [9.53.247.178])
	by austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id WAA11760
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 22:55:06 -0600
Received: from beavis (gsine06.us.sine.ibm.com [9.14.6.46]) by popmail.austin.ibm.com (AIX4.3/8.9.3/8.7-client1.01) with SMTP id WAA26232 for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 22:55:06 -0600
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

> Ok, here is a theory.
> All your data is in cache, right?

Yes

> So when NFSD gets a read request, it hurtles along processing it and
> never has to block all the way until it is completed.  As this is done
> in less than the scheduling interval, it never gets interrupted and no
> other nfsd thread gets to run on that CPU until this one has finished
> it's request.
> This would give you a situation in which you never have more
> concurrent nfsd's than you have processors.

Yes, that seems right.  That actually would not be so bad.  At least I could
achive 100% cpu.

> But you are getting even worse than that:  You have only one active
> thread on a quad processor machine.  I blithely blame this on the
> scheduler.
> Maybe all the nfsd threads are initially attached to the same
> processor, and for some reason they never get migrated to another
> processor.   Is this a question for Ingo Molnar??

I think you are on to something here.  Actually, when monitoring top, I
always have exactly one CPU at 100%, while the others are at ~10%
(interrupts?).  Eventually the 100% moves from one processor to another.
Sounds like the nfsd threads all wake up and stay on the same processor.  I
need to look at how O(1) handles wake_up, and whether it puts all tasks on
the same runqueue, or distributes them amongst <num_cpu> runqueues.

> Maybe when you only have 2 nfsds, the dynamics are a bit different and
> one thread gets migrated and you then get dual processor performance.
>
> Possibly we could put some scheduler call in just after the wake_up()
> in svcsock.c which says to go bother some other CPU???
>
> Does that make any sense, or sound plausable?

Yes.  I could also retest with 4 nfsd threads, each bound to a unique CPU.
I have not looked at Ingo's latest cpu affinity work on O(1), but I'm sure
it can be done.  At some point I wanted to do some experimetation with
process and IRQ affinity anyway.  With samba/netbench I could get 25% better
performance.  In either case, I'll try this and list_add_tail in
svc_serv_enqueue.

> > I am going to setup SpecSFS for a comparison, but IMO I like this test
> > because it runs so quickly and exposes a potential problem.
> >
>
> That's what I was running.... but I had a bug is another
> under-development patch and it locked up chasing a circular list at
> about 2000 Ops/Sec (That is an unpublished number. I didn't publish
> it. You cannot say that I did).

I just got this started today, and I'm having a kernel panic on 1000 Ops in
2.5.7, and I'm not even out of the init phase.  Soon I'll have some more
data.  So far I did see that nfsd_busy get to 12!  However my runqueue
length was still 2 or less.  This obviuosly invloved disk IO (disk was
constantly going).  I need a little more time get get SFS running well to
figure out whats gong on.

Thanks,

-Andrew



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
