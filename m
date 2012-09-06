Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx0.aculab.com ([213.249.233.131]:43197 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756357Ab2IFOib convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Sep 2012 10:38:31 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09380-08 for <linux-nfs@vger.kernel.org>;
 Thu,  6 Sep 2012 15:38:28 +0100 (BST)
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
Date: Thu, 6 Sep 2012 15:36:52 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FDE@saturn3.aculab.com>
In-Reply-To: <5048AAF6.5090101@gmail.com>
References: <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal> <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal> <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal> <20120828230050.GA3337@Krystal> <1346772948.27919.9.camel@gandalf.local.home> <50462C99.5000007@redhat.com> <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal> <5048AAF6.5090101@gmail.com>
From: "David Laight" <David.Laight@ACULAB.COM>
To: "Sasha Levin" <levinsasha928@gmail.com>,
        "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
Cc: "Pedro Alves" <palves@redhat.com>, "Steven Rostedt" <rostedt@goodmis.org>,
        "Tejun Heo" <tj@kernel.org>, <torvalds@linux-foundation.org>,
        <akpm@linux-foundation.org>, <linux-kernel@vger.kernel.org>,
        <linux-mm@kvack.org>, <paul.gortmaker@windriver.com>,
        <davem@davemloft.net>, <mingo@elte.hu>, <ebiederm@xmission.com>,
        <aarcange@redhat.com>, <ericvh@gmail.com>, <netdev@vger.kernel.org>,
        <josh@joshtriplett.org>, <eric.dumazet@gmail.com>, <axboe@kernel.dk>,
        <agk@redhat.com>, <dm-devel@redhat.com>, <neilb@suse.de>,
        <ccaulfie@redhat.com>, <teigland@redhat.com>,
        <Trond.Myklebust@netapp.com>, <bfields@fieldses.org>,
        <fweisbec@gmail.com>, <jesse@nicira.com>,
        <venkat.x.venkatsubra@oracle.com>, <ejt@redhat.com>,
        <snitzer@redhat.com>, <edumazet@google.com>,
        <linux-nfs@vger.kernel.org>, <dev@openvswitch.org>,
        <rds-devel@oss.oracle.com>, <lw@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> My solution to making 'break' work in the iterator is:
> 
> 	for (bkt = 0, node = NULL; bkt < HASH_SIZE(name) && node ==
NULL; bkt++)
> 		hlist_for_each_entry(obj, node, &name[bkt], member)

I'd take a look at the generated code.
Might come out a bit better if the condition is changed to:
	node == NULL && bkt < HASH_SIZE(name)
you might find the compiler always optimises out the
node == NULL comparison.
(It might anyway, but switching the order gives it a better
chance.)

	David



