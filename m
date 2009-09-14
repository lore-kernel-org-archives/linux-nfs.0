From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] idmapd: rearm event handler after error in nfsdcb()
Date: Mon, 14 Sep 2009 14:07:59 -0400
Message-ID: <4AAE867F.8080102@RedHat.com>
References: <1252611727-19078-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1252611727-19078-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/10/2009 03:42 PM, Jeff Layton wrote:
> A couple of years ago, Bruce committed a patch to make knfsd send
> unsigned uid's and gid's to idmapd, rather than signed values. Part
> of that earlier discussion is here:
> 
> http://linux-nfs.org/pipermail/nfsv4/2007-December/007321.html
> 
> While this fixed the immediate problem, it doesn't appear that anything
> was ever done to make idmapd continue working when it gets a bogus
> upcall.
> 
> idmapd uses libevent for its main event handling loop. When idmapd gets
> an upcall from knfsd it will service the request and then rearm the
> event by calling event_add on the event structure again.
> 
> When it hits an error though, it returns in most cases w/o rearming the
> event. That prevents idmapd from servicing any further requests from
> knfsd.
> 
> I've made another change too. If an error is encountered while reading
> the channel file, this patch has it close and reopen the file prior to
> rearming the event.
> 
> I've not been able to test this patch directly, but I have tested a
> backport of it to earlier idmapd code and verified that it did prevent
> idmapd from hanging when it got a badly formatted upcall from knfsd.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.
