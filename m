From: Gopal Santhanam <gopal@nerur.com>
Subject: Re: NFSv3 + ACL + XFS?
Date: Fri, 3 Mar 2006 08:02:37 -0800
Message-ID: <200603030802.37899.gopal@nerur.com>
References: <200603020703.26338.gopal@nerur.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfsv4-bounces@linux-nfs.org>
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
In-Reply-To: <200603020703.26338.gopal@nerur.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Hi all,

Any ideas on the below?

I'm supposing it just doesn't work, but would like to get 
confirmation and some idea why it doesn't work before I decide 
to migrate all of my XFS to EXT3.

Thanks,
Gopal


On Thursday 02 March 2006 07:03, Gopal Santhanam wrote:
> Hi all,
>
> I am successful in exporting an EXT3 partition with ACLs
> through NFSv3.
>
> However, I cannot do the same for an XFS partition with ACLs. 
> I did a quick search on the web and did not easily find any
> information on this.  What's the status on this?  Is there a
> way I can get this to work through proper configuration?
>
> Thanks!
> Gopal
