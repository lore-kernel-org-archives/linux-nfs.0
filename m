From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: RPCGSSD and root on Linux client
Date: Tue, 13 Mar 2007 13:53:43 -0400
Message-ID: <4d569c330703131053u1aab139nf5eb13d682f7e507@mail.gmail.com>
References: <01AE8AF878612047A442668306EAEB055C44F8@SACEXMV01.hq.netapp.com>
	<01AE8AF878612047A442668306EAEB055C4516@SACEXMV01.hq.netapp.com>
	<4d569c330703090724j2bcad85ayca0a383f9ec712f1@mail.gmail.com>
	<4d569c330703090814mae7f6b7hd494e89b5d46b77b@mail.gmail.com>
	<20070310170412.GB29710@fieldses.org>
	<01AE8AF878612047A442668306EAEB055C4663@SACEXMV01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, "Burlyga, Alex" <Alex.Burlyga@netapp.com>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRBC0-00025E-OO
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 10:53:49 -0700
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HRBC2-00047V-85
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 10:53:50 -0700
Received: by ug-out-1314.google.com with SMTP id z38so379206ugc
	for <nfs@lists.sourceforge.net>; Tue, 13 Mar 2007 10:53:45 -0700 (PDT)
In-Reply-To: <01AE8AF878612047A442668306EAEB055C4663@SACEXMV01.hq.netapp.com>
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

On 3/10/07, Muntz, Daniel <Dan.Muntz@netapp.com> wrote:
> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Saturday, March 10, 2007 9:04 AM
> To: Kevin Coffman
> Cc: Muntz, Daniel; Burlyga, Alex; nfs@lists.sourceforge.net
> Subject: Re: [NFS] RPCGSSD and root on Linux client
>
> On Fri, Mar 09, 2007 at 11:14:05AM -0500, Kevin Coffman wrote:
> > After thinking about this a bit more, I have a concern.
> >
> > Let's say root authenticates as "foo@REALM" and begins accessing NFS
> > files using those credentials.  Some time later, the context expires
> > or must be recreated for some reason and root's credentials cache is
> > now either expired or has been destroyed.  The initial context
> > creation will fail and we will fall back and use the machine
> > credentials to create the new context.  This will cause confusion
> > because all of the sudden root is "nfs/<machine>@REALM" rather than
> > "foo@REALM".
> >
> > Any suggestions on a way around this?
>
> We might want to make sure this behavior is optional somehow--it could
> be the reason they have an nfs/host@REALM cred is because the host is
> also an NFS server, not because they want the client using it for root.
>
> Given that, if  a user/administrator sets things up to allow gssd to
> fall back on a different credential, then, well, that's what they asked
> for....
>
> --b.
> Gssd just wants any valid cred.  I'm guessing the '-m' author chose
> nfs[/host]@REALM because they were pretty sure that if you were doing an
> NFS mount that you'd have the nfs service cred :-)  But the current code
> that makes the (once optional) '-m' behavior always on, thus always
> hijacking root, is a problem (imo).
>
>   -Dan

I don't like the idea of things changing suddenly for no apparent
reason (root accesses falling back to using machine creds after other
credentials expire).  I think the default behavior should remain as it
is (using machine creds for root access).  [BTW, making "-m" the
default behavior wasn't a "recent change" and it (the -m option) was
never in an official nfs-utils release.]

I'm tempted to create a new option (-n ?) that says that root should
not use machine credentials.  Use of this option will require that
root authenticates somehow before attempting a mount requiring
Kerberos.

A seperate patch would allow the use of any keytab entry found in the
keytab to be used as the machine credentials.

It seems nfs-utils-1.1.0 might be a good time to introduce this change.

Does that sound reasonable?

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
