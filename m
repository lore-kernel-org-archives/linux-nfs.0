From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st
 part)
Date: Mon, 14 Sep 2009 11:55:46 -0400
Message-ID: <4AAE6782.7000506@RedHat.com>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>	 <20090805144540.12866.22084.stgit@matisse.1015granger.net>	 <20090805174811.GB9944@fieldses.org>	 <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com>	 <20090805181545.GF9944@fieldses.org>	 <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com>	 <1249507356.5428.11.camel@heimdal.trondhjem.org>	 <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com>	 <1249515004.5428.34.camel@heimdal.trondhjem.org>	 <20090909142945.755da393@tlielax.poochiereds.net>	 <1252521599.8722.53.camel@heimdal.trondhjem.org>	 <20B7C2F0-E566-4292-91E9-41A3FA6C9D4C@oracle.com>	 <1252525327.8722.81.camel@heimdal.trondhjem.org>	 <D2B488FA-2630-4355-8E3B-FE1243E4C3AE@oracle.com>	 <9eae93545189a6be6eebe0460b860fc7.squirrel@neil.brown.name>	 <BA66527C-2F6E-4378-8CC1-3
 5B26C444D0E@oracle.com> <1252936467.6866.54.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neilb@suse.de>,
	Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752535AbZINPzw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 11:55:52 -0400
In-Reply-To: <1252936467.6866.54.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The problems with the code remain, and you will need to change it in
> order to make it acceptable. The question I haven't seen you asking, and
> that you should have be asking from the very start is "what would be the
> minimal set of changes?".

I too would like to see what are minimal change set would be... Just
to see how much a db is really needed... If at all.. 

Now with that said... I've taken on the task of how to deal with
pNFS exports and it might make sense that a db is need to deal with
that complexity...  So I'm not totally against the idea of introducing 
a db to nfs-utils I just think we need to do it for the right reason....

steved.
 
