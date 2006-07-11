From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 09:46:35 -0400
Message-ID: <20060711134635.GA11586@fieldses.org>
References: <200607032310.15252.agruen@suse.de>
	<200607110215.53496.agruen@suse.de>
	<3E4B637E-57AC-4E2B-A2C8-EDCFF35A5D84@Sun.COM>
	<200607111005.22200.agruen@suse.de>
	<67359DB9-6E3E-49E7-A8F6-3FB34DCC3440@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lisa Week <Lisa.Week@Sun.COM>, nfsv4@ietf.org, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@Sun.COM>,
	Brian Pawlowski <beepy@netapp.com>, Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfsv4-bounces@ietf.org>
To: Sam Falkner <Sam.Falkner@Sun.COM>
In-Reply-To: <67359DB9-6E3E-49E7-A8F6-3FB34DCC3440@Sun.COM>
List-Unsubscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www1.ietf.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www1.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Errors-To: nfsv4-bounces@ietf.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Jul 11, 2006 at 08:29:21AM -0400, Sam Falkner wrote:
> That's not how Solaris works either.  Sorry, I should have explained  
> it better.  In Solaris using POSIX-draft ACLs, chmod() changes both  
> the group permissions and the mask, simultaneously.  I now understand  
> why you were hesitant to have chmod affect the group permissions, but  
> having it affect both mask and group solves both problems.

I think you're missing the point of his example.  The point is that a
chmod-using application may expect the sequence chmod(600) chmod(664) on
a file with mode 664 to be a no-op.

But if chmod() changes both group and mask bits ("owning group" and
"group file class" bits) then this sequence isn't a no-op any more in
his example.  It gives GROUP@ write permissions.

So Andreas is trying to ensure the property that any sequence of chmod's
that leaves the mode bits the same also leaves the ACL the same.  I
agree that that's a nice property.

What I'm not convinced of yet is that this is really worth caring about
much.  Is this common application behavior?  Have there been complaints
about this from people using Solaris's ACLs?

--b.

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4
