From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: [PATCH] SVC sockets don't disable Nagle
Date: Wed, 30 Apr 2003 14:06:25 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0304301356400.15733-100000@kenzo.iwr.uni-heidelberg.de>
References: <3EAF13B9.8040402@austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AqMB-0007Cm-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 05:06:39 -0700
To: Olof Johansson <olof@austin.ibm.com>
In-Reply-To: <3EAF13B9.8040402@austin.ibm.com>
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

On Tue, 29 Apr 2003, Olof Johansson wrote:

> There is a chance that small requests and replies (~100 bytes) will not
> be aggregated into the same segments but instead sent out separately.

Although I haven't looked at the code recently, I think that what you said 
is true when this is the only request from the client. But what happens 
when there are several requests or when GETATTR calls happen at the same 
time with some data transfer (which is normally the case for a multiuser 
NFS client) ?

> In essence, this will result in some additional network overhead due to
> headers, but the response times will be perceived as faster even for
> slower networks.

True, until the network becomes too slow, then you see "server not 
responding" messages...

> I think it would just clutter the documentation and list of options,

Yes, but Samba has this option and many others and still lots of people 
are using it :-)

> since I don't forsee any practical scenarios in which anyone would have
> a positive performance impact from having Nagle enabled.

Well, my previous message included this question: "What is the impact of 
this change for a slower/congested network ?" So I'll rephrase it: do you 
have some data to show that disabling Nagle does not have a negative 
impact ?

> On a side note: As far as I know, most (all?) other NFS implementations 
> out there already disable Nagle.

I didn't say that the other NFS implementations are better than the Linux 
implementation :-)

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
