From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] [PATCH] NFS server does not update mtime on	setattr	request
Date: Wed, 07 Jun 2006 13:41:32 -0400
Message-ID: <44870FCC.4060300@redhat.com>
References: <4485C3FE.5070504@redhat.com>	 <1149658707.27298.10.camel@localhost> <4486E662.5080900@redhat.com>	 <20060607151754.GB23954@fieldses.org>  <4486F020.3030707@redhat.com>	 <1149694742.26188.6.camel@localhost>  <4486F479.90406@redhat.com> <1149700624.26188.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750883AbWFGRqr@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1149700624.26188.15.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:

>On Wed, 2006-06-07 at 11:44 -0400, Peter Staubach wrote:
>
>  
>
>>I am curious about how this would break truncate?
>>    
>>
>
>According to SuSv43, truncate should result in changes to
>mtime/ctime/suid/sgid if and only if the file size changes. The
>combination of disabling the client caching and always setting
>mtime/ctime on the server will therefore clearly break truncate.
>

Okay, I see that.

Someone should probably alert the Solaris folks that they might have a 
bug in
their NFS clients.  I suspect that they are only sending over the size 
element
in some of the over the wire SETATTR calls when they really should be 
sending
the size and mtime elements.  This might head off a potential customer issue
where they blaim Linux instead of Solaris.

    Thanx...

       ps
