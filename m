From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Wed, 14 Oct 2009 15:30:44 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0910141526530.5279@tundra.namei.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>  <4ACB5FC0.7060307@redhat.com>  <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>  <4AD36C82.8080904@redhat.com>  <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com>  <4AD384BE.2090008@redhat.com>
  <1255388158.3711.57.camel@heimdal.trondhjem.org>  <alpine.LRH.2.00.0910131733070.28896@tundra.namei.org> <1255458444.3711.113.camel@heimdal.trondhjem.org> <alpine.LRH.2.00.0910141134410.4671@tundra.namei.org> <4AD53200.1010100@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Peter Staubach <staubach@redhat.com>,
	Tom Haynes <tdh@excfb.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	David Patrick Quigley <dpquigl@tycho.nsa.gov>,
	Tyler Hicks <tyhicks@linux.vnet.ibm.com>,
	Dustin Kirkland <kirkland@canonical.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4AD53200.1010100@schaufler-ca.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Oct 2009, Casey Schaufler wrote:

> If you wanted to you could implement a mapping scheme of your choice
> on the server.

Just as long as you don't expect any defined semantics from this protocol 
-- it's purely xattr transport.

> A Smack server might be happy with mapping
> nfs.security.SMACK64 to security.SMACK64, while an HP/UX server might
> have a function to map nfs.security.selinux into security.BellAndLaPadula
> for its own nefarious purposes. Because you could do this strictly
> on the server you don't have to implement a negotiation protocol,
> although you could.

I think if we start looking at negotiation & interpretation, then we've 
moved beyond simple metadata transport and should be looking at extending 
NFSv4 instead (e.g. like Labeled NFS).


- James
-- 
James Morris
<jmorris@namei.org>
