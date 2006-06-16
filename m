From: Bryce Harrington <bryce@osdl.org>
Subject: Re: Google Summer of Code and NFSv4
Date: Fri, 16 Jun 2006 11:21:16 -0700
Message-ID: <20060616182116.GC21726@osdl.org>
References: <20060427214838.GR24981@osdl.org> <20060505182549.GA20459@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: nfsv4@linux-nfs.org
In-Reply-To: <20060505182549.GA20459@osdl.org>
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

The announcement went out earlier this week that OSDL is mentoring
several students in the Google Summer of Code program:

 http://www.osdl.org/newsroom/press_releases/2006/2006_06_13_beverton.html

Dipankar Sarkar from the Indian Institute of Technology, will be working
with us on NFSv4 testing.  His project is to create a robustness test
for NFSv4 using NetEm to emulate various network issues (dropped or
delayed packets, partitions, etc.) with various NFSv4 features
(kerberos, acl, delegation, etc.) turned off/on.  This test will be
integrated into Crucible so we will be able to run it as part of the
regular regression tests.

Dipankar's also been keeping a blog so we can follow his progress:
http://nfs4osdl.wordpress.com/

Bryce

> On Thu, Apr 27, 2006 at 02:48:38PM -0700, Bryce Harrington wrote:
> > Hi all,
> > 
> > Google runs a "Summer of Code" project to employ college students to
> > work on open source projects for the summer.  OSDL has signed up as a
> > mentoring organization this year for a few different things, including
> > Linux NFSv4.
> > 
> > If you are a student and interested in working on NFSv4 for the summer,
> > you can find more information at http://developer.osdl.org/dev/soc/ and 
> > http://code.google.com/summerofcode.html .  Proposals can be sent in
> > between May 1st and May 8th.
> > 
> > I've volunteered to be a mentor for any testing projects around NFSv4;
> > there's a couple ideas I listed on the above link, but if you have
> > a better idea for a testing project, please feel free to propose that.
> > In either case, please feel free to contact me off-list to work out
> > details.
> > 
> > Bryce
