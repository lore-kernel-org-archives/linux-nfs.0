Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56196 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab3FDL5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 07:57:32 -0400
Date: Tue, 4 Jun 2013 07:56:44 -0400
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, viro@zeniv.linux.org.uk,
        matthew@wil.cx, dhowells@redhat.com, sage@inktank.com,
        smfrench@gmail.com, swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: Re: [PATCH v1 00/11] locks: scalability improvements for file locking
Message-ID: <20130604115644.GA4180@umich.edu>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
 <20130603213101.GC2109@fieldses.org>
 <20130604065417.46080a57@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130604065417.46080a57@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:

  > Might be nice to look at some profiles to confirm all of that.  I'd also
  > be curious how much variation there was in the results above, as they're
  > pretty close.
  > 
  
  The above is just a random representative sample. The results are
  pretty close when running this test, but I can average up several runs
  and present the numbers. I plan to get a bare-metal test box on which
  to run some more detailed testing and maybe some profiling this week.

Just contributing more runs into the mean doesn't tell us anything about the
variance. With numbers that close you need the variance to tell whether it's
a significant change.
