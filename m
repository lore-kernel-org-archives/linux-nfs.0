From: Jason Baron <jbaron@redhat.com>
Subject: Re: [patch 0/5] activate & deactivate dprintks individually and
	severally
Date: Wed, 21 Jan 2009 10:28:58 -0500
Message-ID: <20090121152858.GA23953@redhat.com>
References: <20090120012930.020621000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>,
	Linux NFSv4 ML <nfsv4@linux-nfs.org>,
	SystemTAP ML <systemtap@sources.redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090120012930.020621000@sgi.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 20, 2009 at 12:29:30PM +1100, Greg Banks wrote:
> 
> As mentioned in the recent discussion on NFS trace points on the NFS &
> SystemTap mailing lists.  This patch allows field support staff and
> kernel developers debug kernel problems, by enabling them to treat
> dprintks as precise trace points rather than syslog spamming tools.
> 
> This is a forward ported (from 2.6.16), updated, and split version
> of a patch that has been used in SGI's internal development tree for
> the last few months.  The very first version of this was used about
> eighteen months ago when debugging NFS/RDMA, which has an enormous
> number of dprintks and no other way to debug it.
> 
> Jason Baron suggested I post it here for review and contrast with
> his dynamic dprintk feature.
> 

yes, these two patch sets are very similar in the problem that they are
addressing. For me, one of the core differences, is that 'dprintk' has
per-debug statement control, while my solution, 'dynamic debug' has a
more per-module focused control. 'dprintk' thus checks a different
variable per-debug line to see if its enabled. On the other hand
'dynamic debug' can check 1 global variable (in the most common cases),
to see if its enabled or not. I think we can layer per-line check on top
of the 1 global variable check and have a more efficient solution that
still allows for fine-grained debugging.

'dprintk' also has a richer user interface, which allows for file, line,
module, and statement control. 

Thus, I think Greg and I can work together and combine the best features
of both patches. We will re-post a combined solution.

thanks,

-Jason
