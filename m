From: Olaf Kirch <okir@suse.de>
Subject: Re: [NFS] [PATCH][RFC] use completions instead of sleep_on for rpciod
Date: Tue, 10 Feb 2004 10:18:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040210091808.GE20932@suse.de>
References: <20040207144405.GA19416@lst.de> <20040209102801.GC21364@suse.de> <40283952.6093F19D@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com,
        nfs@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <40283952.6093F19D@melbourne.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-ID: <nfs.lists.sourceforge.net>

On Tue, Feb 10, 2004 at 12:52:18PM +1100, Greg Banks wrote:
> Yes but it's worth doing, especially serverside.

I won't argue that point. But I've had to deal with the fall-out from
"oh-well-they-seem-to-work-here" type of NFS BKL removal patches, so
I'm quite wary of adding anything at this point in the game :)

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 
