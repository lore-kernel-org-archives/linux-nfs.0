From: Lawrence Ong <lawrence.ong@netregistry.com.au>
Subject: Re: SM_UNMON again -> kernel
Date: Tue, 15 Jul 2003 09:42:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030714234226.GA24258@quasar.nro.au.com>
References: <20030711061615.GA1924@quasar.nro.au.com> <shsr84x768e.fsf@charged.uio.no> <20030713042557.GA12903@quasar.nro.au.com> <shsu19pijev.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.netregistry.net ([203.202.16.100] helo=roanoak.netregistry.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19cCz5-0000JE-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 16:43:56 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsu19pijev.fsf@charged.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, Jul 14, 2003 at 10:47:52AM +0200, Trond Myklebust wrote:
> >>>>> " " == Lawrence Ong <lawrence.ong@netregistry.com.au> writes:
> 
>      > Anyhow, it shows that the kernel is still continually sending
>      > out unmonitor packets to statd at regular intervals.  What the?
>      > Why is this happening?
> 
> What's wrong with that: I presume you *are* releasing locks every now
> and then?

How often should you be releasing locks?  Right now, on the client and
server, it is happening about every 5 minutes.

> There's no point in monitoring a server on which you're not holding
> any locks.

Well, in that case, the only way to make the erroneous SM_UNMON really go
away is by adding: 127.0.0.1 localhost mymachine to /etc/hosts.
I know you said that's bad, but how else would you do it when the MON
function for nfs-utils actually set the my_name variable to 127.0.0.1?

Maybe i'm missing something, but so far, the only ways i see that the
erroneous message would ever disappear are:

a. By putting in 127.0.0.1 localhost mymachine in /etc/hosts
b. By having the kernel STOP sending out unmonitor packets to statd at
   regular intervals
c. By changing statd so that it does not set my_name to 127.0.0.1
   (breaks fix? for CERT CA-99.05).

If you think that there is another way to stop that erroneous SM_UNMON
error, without doing any of those ridiculous fix above, I would be willing
to test it out.  Thanks.

Cheers,
Lawrence


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
