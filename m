From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Tue, 24 Apr 2007 13:13:05 -0400
Message-ID: <462E3AA1.8080904@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>	<20070419012154.GB19063@javifsp.no-ip.org>	<17960.11704.321124.641669@notabene.brown>	<4629120C.60803@RedHat.com>	<17964.12324.307985.65596@notabene.brown>	<17964.21206.435402.157895@notabene.brown>	<462CB7F9.2040800@RedHat.com>
	<17965.21960.121292.462553@notabene.brown>
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
	id 1HgOZi-0006K9-Et
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 10:13:10 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgOZk-000180-QK
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 10:13:13 -0700
In-Reply-To: <17965.21960.121292.462553@notabene.brown>
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
>>
>> I guess I've become a fan of letting autoconf (and friends) create
>> the makefiles verses me hacking on them... although working with
>> that autoconf API can drive one to drink (which it has ;-) ) but
>> in the end, I do think it makes things a be more configurable...
> 
> Conversely, I find autoconf and friends deeply unsatisfying.  Both the
> configure.in and the generated files are just so .... messy.
I can't agree with you more...

> 
> Yes: if you have autoconf in place, you approach is very sensible.
> But I would like to avoid autoconf where possible.  Hopefully portmap
> is simple enough that it will remain possible.
Makes sense... I'm always a fan of keeping things simple!

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
