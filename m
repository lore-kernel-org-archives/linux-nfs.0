From: "John Ronciak" <john.ronciak@gmail.com>
Subject: Re: NFS regression? Odd delays and lockups accessing
	an NFS export.
Date: Fri, 22 Aug 2008 12:33:07 -0700
Message-ID: <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	<1219087258.7192.19.camel@localhost>
	<1219400624.18774.67.camel@zakaz.uk.xensource.com>
	<1219428489.6919.21.camel@localhost>
	<1219428818.27921.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, Grant Coady <gcoady.lk@gmail.com>,
	e1000-devel@lists.sourceforge.net, neilb@suse.de,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>, bfields@fieldses.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: "Ian Campbell" <ijc@hellion.org.uk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1219428818.27921.43.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 22, 2008 at 11:13 AM, Ian Campbell <ijc@hellion.org.uk> wrote:

>> That's probably also a networking device driver issue candidate: your
>> RPC task is queued up waiting to be sent.
>>
>> What networking card+device driver are you using here?
>
> # ethtool -i eth0
> driver: e1000
> version: 7.3.20-k2-NAPI
> firmware-version: N/A
> bus-info: 0000:01:0a.0
There is nothing indicating that the NIC/driver is causing any sort of
problem here, at least not with what has been presented so far.  When
the NFS mount isn't working is the networking still active and
working?

-- 
Cheers,
John

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
