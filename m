From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
Date: Thu, 24 Jun 2010 08:44:03 -0500
Message-ID: <20100624134403.GA9479@hallyn.com>
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org>
 <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org>
 <20100624043351.GA6024@hallyn.com>
 <alpine.LRH.2.00.1006241825580.3960@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-security-module@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-fsdevel@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>
To: James Morris <jmorris@namei.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1006241825580.3960@tundra.namei.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting James Morris (jmorris@namei.org):
> On Wed, 23 Jun 2010, Serge E. Hallyn wrote:
> 
> > > +	status = res.xattr_val_len;
> > > +	if (status <= size)
> > 
> > res.xattr_val_len was set to size, as was status, and none of the
> > 3 has been changed, so here status can't be > size can it?
> 
> res is part of msg, and is updated by the RPC layer when decoding the 
> response (via xdr_decode_string_inplace()).

Ah, I see, it's passed in as a member of msg.  Thanks.

> > Was this just a safety to prevent overrun, or did you mean to
> > do some other check?  (If a safety, then you'll still return
> > status > size, but with garbage in value, so i think you'd want
> > to also change status)
> > 
> > > +		memcpy(value, res.xattr_val, status);
> > 
> 
> Yes, the check stops us from copying more than the max. expected size to 
> 'value'.
> 
> It looks like we do need to return -EINVAL if the check fails, and likely 
> the same with listxattr().  (Or is there a better error code for reporting 
> invalid messages from the peer?)

That'd be my pick.

-serge
