From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Mon, 23 Apr 2007 09:28:54 -0400
Message-ID: <462CB496.6000308@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>	<20070419012154.GB19063@javifsp.no-ip.org>	<17960.11704.321124.641669@notabene.brown>	<4629120C.60803@RedHat.com>
	<17964.12324.307985.65596@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <olaf.kirch@oracle.com>,
	=?ISO-8859-1?Q?Javier_Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hfyaa-0001Di-6G
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 06:28:20 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hfyac-0001o3-Gq
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 06:28:22 -0700
In-Reply-To: <17964.12324.307985.65596@notabene.brown>
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



Neil Brown wrote:
> On Friday April 20, SteveD@redhat.com wrote:
>> Is there any particular reason your staying with portmap
>> instead of moving on to rpcbind? 
> 
> I want distros to include the functionality I want (non-priv users
> cannot remove registrations of non-priv ports registered by priv
> users).  Given the two approaches:
>    - please use newer version of portmap
>    - please dump portmap and use rpcbind
> I suspect the former to be more effective.
Probably... but the latter will need to happen if/when
IPv6 supports is wanted...

> 
> I'm not against moving to rpcbind, it is probably a very good idea.
> But I expect there to be more resistance.
> If everyone goes to rpcbind and no-one uses 'my' portmap, that would
> be fine with me.
Good... and I didn't think you were against anything... I wanted
let you know there was an alternative

> 
>> I (hastily) created two git trees:
>> git://git.infradead.org/~steved/libtirpc.git
>> git://git.infradead.org/~steved/rpcbind.git
>>
>> I think if you take a look, you'll see that
>> this code may not be as mature as the portmap
>> code, but its a much better start... imho..
> 
> Yes, very hasty.  Several #temporary# and back~ files :-)
Yeah... for some reason those temporary files are in the
the tar ball... I'll work to get that cleaned up..

> 
> I notice that it has a concept of who 'owns' a registration, but it
> only works if unix-domain sockets are used for the registration.
> Adding 'superuser' ownership for localhost/privport registrations is
> probably a 3 line patch....
I'm not sure I understand.. are you talking about how getowner()
is being used?

> 
> So: yes.  Full steam ahead on rpcbind.  But short-term I think it is a
> good idea to give portmap a little more life.
I agreed... portmapper will be around for a long while...

steved


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
