Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <4C761A61.2070203@panasas.com>
Date: Thu, 26 Aug 2010 10:40:17 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: Linux pNFS status meeting 08/26
References: <OFED8B9B7B.45CD28BB-ON8825777C.005B88F3-8825777C.005BC3F5@us.ibm.com>
	<OF1477B0A3.3F72D2BF-ON88257783.005FBF98-88257783.005FDE25@us.ibm.com>
	<OFF2C1BE64.0E5C418F-ON8825778B.001353F9-8825778B.00136C6A@us.ibm.com>
In-Reply-To: <OFF2C1BE64.0E5C418F-ON8825778B.001353F9-8825778B.00136C6A@us.ibm.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 26, 2010, 6:32 +0300, Marc Eshel <eshel@almaden.ibm.com> wrote:
> Meeting on Thursday 08/26/10 at 9:30 AM pacific time (12:30 PM UMICH time)

Sorry, I can't make it today.
Latest status: pnfs-all-2.6.35-2010-08-24 was released with
the latest pnfs-submit branch, including Andy's renaming work
and his fix of a rcu bug in pnfs deviceid cache found by Fred.

I applied the renames onto the rest of the generic pnfs code and
layout drivers as well as renamed code for the callback path
to match the existing naming convention. I also cleaned up
the patchset itself to get it one step closer for the next step.

Right now I'm rebasing the tree onto 2.6.36-rc1 and will release
the rebased version after giving it a good test.

The next step is reorganize the patchset into shorter runs and
possibly squash together some small patches into bigger ones as
we discussed so to make it easier for review.

Benny

> 
> Marc. 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
_______________________________________________
NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org instead.
(To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org.)

NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
