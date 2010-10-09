From: Valerie Aurora <vaurora@redhat.com>
Subject: Re: [PATCH 08/17] Make follow_down() handle d_manage()
Date: Fri, 8 Oct 2010 20:28:31 -0400
Message-ID: <20101009002831.GG30846@shell>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk> <20100930181536.30939.6776.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org, jmoyer@redhat.com, linux-fs@vger.kernel.org,
	autofs-CPWUtch7KCBzeIdxy0IIJw@public.gmane.org, linux-kernel@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org, Ian Kent <raven@themaw.net>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-cifs-owner@vger.kernel.org>
In-Reply-To: <20100930181536.30939.6776.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-cifs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 30, 2010 at 07:15:36PM +0100, David Howells wrote:
>  }
>  
>  /*
> + * Follow down to the topmost point on a stack of mountpoints.  At each point,

"Follow down to the topmost" -> "Follow down to covering mount" ?

-VAL
