From: Nathan Ollerenshaw <nathan@valuecommerce.co.jp>
Subject: Re: Help diagnosing bizarre NFS problem
Date: Thu, 27 Jan 2005 11:25:13 +0900
Message-ID: <ACEF13F1-700A-11D9-89EE-000A95A07AB8@valuecommerce.co.jp>
References: <BA594DD2-65DA-11D9-B0EB-000A95A07AB8@valuecommerce.co.jp> <731336CA-6DE6-11D9-8B4D-000A95A07AB8@valuecommerce.co.jp> <Pine.LNX.4.58.0501241116080.23996@lewis.et.byu.edu>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtzLT-0001UN-Jg
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 18:25:19 -0800
Received: from f8a01-0447.din.or.jp
	([61.122.67.147] helo=elmo.stupendous.net ident=nobody)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CtzLR-0006eR-3d
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 18:25:19 -0800
In-Reply-To: <Pine.LNX.4.58.0501241116080.23996@lewis.et.byu.edu>
To: David Dougall <davidd@et.byu.edu>
Sender: nfs-admin@lists.sourceforge.net
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

On Jan 25, 2005, at 3:17 AM, David Dougall wrote:

> In that past when I get that error message and dropping the rsize/wsize
> fixes it, it is directly related to a network problem.
> buggy network driver
> speed mismatch between client/server(tcp solves this usually)
> flaky wiring/switch/etc
> --David Dougall

That was my first guess too, but I checked the switches and the 
clients; autoneg is working fine and there are no errors on any of the 
interfaces on the switches or the client machines.

The vendor is saying they think they have found the problem. I don't 
know yet, I won't believe it until I see the patch ;)

Nathan.

-- 
"It is change, continuing change, inevitable change, that is
  the dominant factor in society today. No sensible decision can
  be made any longer without taking into account not only the
  world as it is, but the world as it will be." - Isaac Asimov



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
