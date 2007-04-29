From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Sun, 29 Apr 2007 19:39:15 -0400
Message-ID: <46352CA3.9090104@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<200704251056.03664.olaf.kirch@oracle.com>
	<46312615.2090307@RedHat.com>
	<200704270820.19718.olaf.kirch@oracle.com>
	<46320251.8050900@redhat.com> <20070427140931.GA9998@infradead.org>
	<463206D4.9050504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Aurelien.Charbon@ext.Bull.Net,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiIyP-0008MQ-Qs
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 16:38:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiIyR-0001do-7d
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 16:38:36 -0700
In-Reply-To: <463206D4.9050504@redhat.com>
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

Peter Staubach wrote:
>>
>> I don't think the problem is that we can't maintain it, but rather
>> that no one stepped up to maintain it so far.
>>   
> 
> I had the impression that SteveD had stepped up.  Or am I speaking out of
> turn for him?  :-)
Since the libtirpc is already in FC6 (extras) and will be in FC7, I
have every intention on help the Bull people in maintaining this
code...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
