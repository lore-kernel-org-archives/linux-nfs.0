From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: NFS file locking for clustered filesystems
Date: Mon, 16 Aug 2004 17:46:02 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0408121732450.2954@localhost.localdomain>
References: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
 <20040802105103.GJ25023@suse.de>  <1091461098.3980.22.camel@lade.trondhjem.org>
  <Pine.LNX.4.58.0408101139260.11489@localhost.localdomain>
 <1092184994.5857.19.camel@lade.trondhjem.org>
 <Pine.LNX.4.58.0408111155570.2546@localhost.localdomain>
 <1092288885.4079.40.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwsDb-0006DR-Is
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 17:52:51 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Bws8v-0008JM-CR
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 17:52:51 -0700
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1Bws8q-0000xl-QP
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 17:47:57 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1092288885.4079.40.camel@lade.trondhjem.org>
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

On Wed, 11 Aug 2004, Trond Myklebust wrote:

> P=E5 on , 11/08/2004 klokka 14:35, skreiv Sridhar Samudrala:
>
> > So, in the case of a client which doesn't allow blocking, are you sugge=
sting
> > that the cluster filesystem to return LCK_BLOCKED immediately and start=
 the
> > asynchrous call and return LCK_DENIED in a few seconds if it cannot com=
plete
> > the operation?
>
> Sort of.
>
> Firstly, having the filesystem return NLM-specific errors is a no-no.
> Lets keep the errors generic (-EAGAIN =3D=3D -EWOULDBLOCK for instance.)
> NFSv4 does not understand LCK_BLOCKED.

I didn't meant the filesystem to return NLM-specific errors. Just to make i=
t
simple, i used the return values from the nlmsvc routines after they are
converted from the generic errors returned by the filesystem calls. Sorry f=
or
the confusion.

>
> Secondly, I suggest that lockd should manage its timeouts itself rather
> than relying on the clustered filesystem to do so. Timers are cheap...

An issue with using a timer to validate that the filesystem call is not
blocking too long is that it could generate false positives because the cal=
l
  - might get pre-empted
  - might take a long interrupt
  - might encounter hw problem resulting in machine-check exception etc.

Instead, we can disable preemption before the call and validate that there
were no context switches after the filesystem call returns.

      preempt_disable();
      nctx =3D RCU_qsctr(task_cpu(current));
      file_system_lock();
      if (nctx !=3D RCU_qsctr(task_cpu(current))) {
 =09  printk(KERN_WARNING "filesystem call did not return immediately");
      }
      preempt_enable();

Is this approach acceptable?

>
> > But i am not sure if we can handle this easily with the current design =
of
> > lockd. As soon as the lock operation returns LCK_BLOCKED, i think svc_s=
end() is
> > called from svc_process() which will send a reply with NLM_BLOCKED.
>
> For NFSv4 this is not a problem: NFS4ERR_DELAY will make the client back
> off and retry the request later.
>
> For NLM, you are clearly going to have to figure out a way around the
> above problem. (but that's why you get paid the big bucks right? ;-))
> Note that the sunrpc server code already has a mechanism for deferring
> requests when dealing with blocking behaviour (in case it needs to do an
> upcall) and then replaying them later. Perhaps you could look into
> reusing that here?

I started looking into the sunrpc server code. I guess you meant svc_defer(=
)
as a mechanism to defer the requests.
Is this mechanism currently used for any lockd RPC calls? I guess it is use=
d
only for nfsd RPC calls.
Could you please give an example when a request is deferred?

Thanks
Sridhar

>
> Cheers,
>   Trond
>
>


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
