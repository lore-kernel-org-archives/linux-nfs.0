From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: nfsstat limitations?
Date: Mon, 25 Mar 2002 11:36:18 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C9F7C32.CD3D5A47@attbi.com>
References: <3C9F4BCD.5050404@saepio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16paFL-00078m-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 11:35:11 -0800
To: Matthew Boeckman <matthewb@saepio.com>
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

Matthew Boeckman wrote:
> 
> Hello list!
> 
> I'm trying to track down some information about the nfsstat on linux.
> Specifically from nfs-utils-0.3.1-5 on RH7.1 . What I'm looking for is
> some additional client RPC information. nfsstat on solaris gives me all
> kinds of nifty output about timeouts, badcalls, timers, etc:
> Client rpc:
> Connection oriented:
> calls       badcalls    badxids     timeouts    newcreds    badverfs
> 0           0           0           0           0           0
> timers      cantconn    nomem       interrupts
> 0           0           0           0
> Connectionless:
> calls       badcalls    retrans     badxids     timeouts    newcreds
> 4           1           0           0           0           0
> badverfs    timers      nomem       cantsend
> 0           1           0           0
> 
> on linux:
> Client rpc stats:
> calls      retrans    authrefrsh
> 70163      12         0
> 
> I've read the man page and docs on the sourceforge site, and it doesn't
> appear that I'm missing any command line options. Is there somewhere
> other than nfsstat that I can get this info?
> 
> Another question along the same lines: how can I track client side NFS
> cache hit's and caching information in general? For a variety of
> reasons, I'm caching the entire mounted filesystem for a long time, and
> am interested/concerned in being able to track the system impact of
> that. Things like, of all NFS calls, how many are being answered by the
> cache, how much system resources is this cache taking up, etc. Thanks
> for any and all replies!
> 
> -Matthew

Either the 0.3.1 version of nfsstat defaults to nfsstat -r -c
(which I doubt) or you have an alias which is doing that behind
your back.  The default for 0.3.3 utils (which are easy to install
and should be used) would show both client and server stats for
rpc and nfs versions 2 & 3.

Tom

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
