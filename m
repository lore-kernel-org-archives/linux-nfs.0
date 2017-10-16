Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46266 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755115AbdJPSu6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Oct 2017 14:50:58 -0400
Date: Mon, 16 Oct 2017 14:50:58 -0400
To: John Ratliff <john@bluemarble.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs group permissions not recognized between linux systems
Message-ID: <20171016185058.GD12608@fieldses.org>
References: <0c3db682-8838-d718-471f-3c086c03088b@bluemarble.net>
 <e3a884c4-04cf-621c-01bb-4853ba37e704@bluemarble.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <e3a884c4-04cf-621c-01bb-4853ba37e704@bluemarble.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 14, 2017 at 09:54:47PM -0400, John Ratliff wrote:
> On 10/14/2017 7:11 PM, John Ratliff wrote:
> >I have been working on trying to setup an NFS server, but my
> >clients cannot access the files after mounting.
> >
> >It seems to be a problem with group permissions, but I can't
> >figure out why.
> >
> >My server is a debian 9 machine with kernel 4.9.51. If I use a
> >debian client, either Debian 8 or Debian 9, everything works fine.
> >However, if I try with an Ubuntu 14.04, 16.04, or CentOS 7 client,
> >they cannot access the files.
> >
> >My directory on the server has permissions 2750. It is owned by
> >root with ssl-cert as the group. The ssl-cert group ID is 555. I
> >have made sure that same group is on all the client machines and
> >has the same ID of 555. The users I am trying to have access the
> >files are members of this group. Yet I keep getting permission
> >denied.
> >
> >I have turned off the firewall (both on server and client). I have
> >put ALL:ALL in /etc/hosts.allow. The machines are in the same
> >subnet. They can ping one another and can SSH freely between them.
> >
> >I have tried NFS v3 and NFS v4, but this doesn't matter.
> >
> >This is my /etc/exports
> >
> >/etc/ssl/wildcard.smithville.com 192.168.1.0/24(rw,sync,no_subtree_check)
> >
> >I've tried making the Ubuntu 16.04 machine the server and the
> >Debian machine the client, but I have the same problem (but Ubuntu
> >to Ubuntu is fine, and Ubuntu server to CentOS 7 client works).
> >
> >I'm not sure how to further troubleshoot.
> >
> >Thanks for any suggestions.
> >
> >-- 
> >To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> After much googling, I have found the answer.
> 
> The Debian NFS server, by default, uses --manage-gids in the
> RPCMOUNTDOPTS in /etc/default/nfs-kernel-server. I guess I never
> looked very hard at that option, but what it means is that group
> membership is checked on the server, not trusted from the client.
> This is a good thing overall; it improves security and overcomes a
> limitation of the NFS protocol (16 group count).
> 
> In my case, the user on the client I was testing was UID 1003, which
> on the server he was UID 1000. So they both had the group, but UID
> 1003 on the server did not have the group, because that user did not
> exist. Therefore, permission denied.
> 
> Although it's not the best solution from a security standpoint, I'm
> going to disable the manage-gids option for now and limit access by
> hosts.allow and the firewall.

Thanks for following up.

I think the manage-gids option is still the right default, but it can be
confusing in a case like this.

--b.
