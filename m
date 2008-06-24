From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: Upcoming nfs-utils 1.1.3 release.
Date: Tue, 24 Jun 2008 21:41:16 +0200
Message-ID: <20080624194116.GN4484@ics.muni.cz>
References: <48600CCC.5000203@RedHat.com> <20080623205704.GU4484@ics.muni.cz>
	<486016B2.1000506@RedHat.com> <20080624083355.GW4484@ics.muni.cz>
	<4d569c330806240634m6c23e3den338e7c3842d9e261@mail.gmail.com>
	<20080624153741.GM4484@ics.muni.cz>
	<4d569c330806241027n1f717a19o371e7bf41b5b203f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c330806241027n1f717a19o371e7bf41b5b203f@mail.gmail.com>
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

On Tue, Jun 24, 2008 at 01:27:50PM -0400, Kevin Coffman wrote:
> Near as I can tell, the use of strnstr() is from your patch?
> select_krb5_ccache() uses strstr().

I guess no. I believe it came to me from git head.

-- =

Luk=E1=B9 Hejtm=E1nek
