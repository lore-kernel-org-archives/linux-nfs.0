From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Performance problem
Date: Mon, 13 May 2002 09:48:35 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020513094835.A1768@wumpus.keyresearch.com>
References: <1021302616.27660.20.camel@nb> <1021307724.2651.3.camel@twitch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nixon.xkey.com ([209.245.148.124])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Izf-0006Ut-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 09:48:15 -0700
Received: (from lindahl@localhost)
	by localhost.conservativecomputer.com (8.11.6/8.11.0) id g4DGmZp01776
	for nfs@lists.sourceforge.net; Mon, 13 May 2002 09:48:35 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1021307724.2651.3.camel@twitch>; from dritch@hpti.com on Mon, May 13, 2002 at 12:35:24PM -0400
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

On Mon, May 13, 2002 at 12:35:24PM -0400, David B. Ritch wrote:

> Make sure that your server and clients agree on the MTU of the network. 
> I don't recall having seen the request slot message associated with that
> sort of problem, but an MTU problem can cause messages to be dropped.

Anything that causes packets to get discarded can cause the request
slot message. The MTU thing can be tested by pinging with 8192 byte
packets, which is also a good way to figure out if your network has
enough lossage to cause big UDP packets to be unlikely to arrive,
while short ones work fine. And other things that go bump in the
night.

greg


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
