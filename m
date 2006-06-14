From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] [RFC] NLM lock failover admin interface
Date: Wed, 14 Jun 2006 09:39:04 -0400
Message-ID: <1150292344.28264.87.camel@localhost.localdomain>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
	<20060614113605.GA28158@infradead.org>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-cluster@redhat.com
Return-path: <linux-cluster-bounces@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060614113605.GA28158@infradead.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cluster>
List-Post: <mailto:linux-cluster@redhat.com>
List-Help: <mailto:linux-cluster-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=subscribe>
Sender: linux-cluster-bounces@redhat.com
Errors-To: linux-cluster-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-06-14 at 12:36 +0100, Christoph Hellwig wrote:
> On Wed, Jun 14, 2006 at 02:54:51AM -0400, Wendy Cheng wrote:
> > Hi,
> > 
> > KABI (kernel application binary interface) commitment is a big thing
> > from our end - so I would like to focus more on the interface agreement
> > before jumping into coding and implementation details. 
> 
> Please stop this crap now.  If zou don't get that there is no kernel internal
> ABI and there never will be get a different job ASAP.

Actually I don't quite understand this statement (sorry! English is not
my native language) but it is ok. People are entitled for different
opinions and I respect yours.  

On the technical side, just a pre-cautious, in case we need to touch
some kernel export symbols so it would be nice to have external (and
admin) interfaces decided before we start to code. 

So I'll not talk about this and I assume we can keep focusing on NLM
issues. No more noises from each other. Fair ?

-- Wendy
