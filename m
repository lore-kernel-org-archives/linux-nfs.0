From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Linux-cluster] [RFC] NLM lock failover admin interface
Date: Mon, 12 Jun 2006 13:23:02 -0400
Message-ID: <448DA2F6.8080605@RedHat.com>
References: <1150089943.26019.18.camel@localhost.localdomain>	<20060612150053.GC31596@fieldses.org>
	<448D8BF7.7010105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux clustering <linux-cluster@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fpq8D-0003GI-6b
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 10:23:17 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fpq8C-00079W-34
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 10:23:17 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <448D8BF7.7010105@redhat.com>
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

Wendy Cheng wrote:
> The nice thing about this approach is the recovery part - the take-over 
> server can use the counter part command to export and set grace period 
> for one particular interface within the same system call.
Actually this is a pretty clean and simple interface... imho..
The only issue I had was adding a flag to an older version and then
having to carry that flag forward... So if this interface is
accepted and added to the mainline nfs-utils (which it should be.. imho)
that fact it is so clean and simple would make the back porting fairly
trivial...

steved.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
