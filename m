From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Upcoming nfs-utils 1.1.3 release.
Date: Mon, 23 Jun 2008 17:33:38 -0400
Message-ID: <486016B2.1000506@RedHat.com>
References: <48600CCC.5000203@RedHat.com> <20080623205704.GU4484@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080623205704.GU4484@ics.muni.cz>
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



Lukas Hejtmanek wrote:
> Hello,
> 
> On Mon, Jun 23, 2008 at 04:51:24PM -0400, Steve Dickson wrote:
>> I'm thinking about making a 1.1.3 nfs-utils update release in the relatively
>> near future. I've made about  20 or so commits since the last release so
>> I was thinking that was a nice round number to cut a release... 
>>
>> So if your sitting on some patches that you want include please post them to
>> the list. Also if you don't see something in the git tree that should be
>> there (i.e.  I missed the patch posting) please bring it to my attention... 
> 
> have there been any changes to rpc.gssd since 1.1.2? 
I just took quick look and no there does not appear to be any rpc.gssd changes.
I think the last ones to go in were the "[PATCH 0/4] nfs-utils gssd" patch
set that Kevin posted. 

> Searching for a proper kerberos ticket was broken. I have patches to fix it and also adding an extra
> option to set preffered realm of the tickets (it comes handy in cross-realm
> environment). I would like to see these patches included.
Sorry I must have missed the posting... would you mind sending me a pointer
to those posting?

tia,

steved.
