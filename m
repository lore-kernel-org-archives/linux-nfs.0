From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS file locking for clustered filesystems
Date: Tue, 17 Aug 2004 14:00:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092765617.4030.55.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
	 <20040802105103.GJ25023@suse.de>
	 <1091461098.3980.22.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0408101139260.11489@localhost.localdomain>
	 <1092184994.5857.19.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0408111155570.2546@localhost.localdomain>
	 <1092288885.4079.40.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0408121732450.2954@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxD6S-0001oB-Ig
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 16:10:52 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BxD6Q-0000Sv-Q7
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 16:10:52 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1Bx8HE-0005yU-O8
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 11:01:41 -0700
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0408121732450.2954@localhost.localdomain>
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

P=E5 m=E5 , 16/08/2004 klokka 20:46, skreiv Sridhar Samudrala:

> An issue with using a timer to validate that the filesystem call is not
> blocking too long is that it could generate false positives because the c=
all
>   - might get pre-empted
>   - might take a long interrupt
>   - might encounter hw problem resulting in machine-check exception etc.

I don't understand. The above are all things that will occur on short
timescales (~ 1/100 seconds). If we're talking timeouts of the order of
seconds, none of them will be significant.

> Instead, we can disable preemption before the call and validate that ther=
e
> were no context switches after the filesystem call returns.

Huh? I think you misunderstand me. I'm not talking about timing the call
to file_system_lock(). That's not supposed to sleep anyway...

I'm talking about the case where the filesystem "forgets" to call us
back afterwards (because it is unable to contact the cluster lock
manager or something like that). For *that* case we need to be able to
time out after a few seconds and return an ENOLOCK error (LCK_DENIED) to
the client.

> >
> > > But i am not sure if we can handle this easily with the current desig=
n of
> > > lockd. As soon as the lock operation returns LCK_BLOCKED, i think svc=
_send() is
> > > called from svc_process() which will send a reply with NLM_BLOCKED.
> >
> > For NFSv4 this is not a problem: NFS4ERR_DELAY will make the client bac=
k
> > off and retry the request later.
> >
> > For NLM, you are clearly going to have to figure out a way around the
> > above problem. (but that's why you get paid the big bucks right? ;-))
> > Note that the sunrpc server code already has a mechanism for deferring
> > requests when dealing with blocking behaviour (in case it needs to do a=
n
> > upcall) and then replaying them later. Perhaps you could look into
> > reusing that here?
>=20
> I started looking into the sunrpc server code. I guess you meant svc_defe=
r()
> as a mechanism to defer the requests.
> Is this mechanism currently used for any lockd RPC calls? I guess it is u=
sed
> only for nfsd RPC calls.
> Could you please give an example when a request is deferred?

It is for instance currently used in the case where auth_unix needs to
do an upcall to userland in order to find out whether or not the user is
authorized.

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
